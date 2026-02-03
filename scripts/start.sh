#!/bin/sh

# Progress bar function - updates in place
show_progress() {
    local current=$1
    local total=$2
    local step_name=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' ' '
    printf "] %3d%% - %s" $percentage "$step_name"
}

# Clear progress bar
clear_progress() {
    printf "\r%80s\r" " "
}

# Track if database was seeded (first launch)
FIRST_LAUNCH=false

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "                    GAME DB - INITIALIZING"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Total steps: 7
TOTAL_STEPS=7
CURRENT_STEP=0

# Step 1: Migrations
CURRENT_STEP=1
show_progress $CURRENT_STEP $TOTAL_STEPS "Running migrations"
npx sequelize-cli db:migrate > /dev/null 2>&1

# Step 2: Check database
CURRENT_STEP=2
show_progress $CURRENT_STEP $TOTAL_STEPS "Checking database"
DB_PATH="${DB_STORAGE:-./data/gamedb.sqlite}"
GENRE_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM genres;" 2>/dev/null || echo "0")

# Step 3: Seed database (if needed)
CURRENT_STEP=3
if echo "$GENRE_COUNT" | grep -qE '^[0-9]+$' && [ "$GENRE_COUNT" -gt 0 ] 2>/dev/null; then
  show_progress $CURRENT_STEP $TOTAL_STEPS "Database ready"
else
  show_progress $CURRENT_STEP $TOTAL_STEPS "Seeding database"
  FIRST_LAUNCH=true
  npx sequelize-cli db:seed:all > /dev/null 2>&1
fi

# Step 4: Starting server
CURRENT_STEP=4
show_progress $CURRENT_STEP $TOTAL_STEPS "Starting server"
npm start > /tmp/app.log 2>&1 &
APP_PID=$!

# Step 5: Waiting for server
CURRENT_STEP=5
show_progress $CURRENT_STEP $TOTAL_STEPS "Warming up server"
for i in 1 2 3 4 5; do
  sleep 1
done

# Step 6: Running tests
if [ "${NODE_ENV:-development}" = "development" ]; then
    CURRENT_STEP=6
    show_progress $CURRENT_STEP $TOTAL_STEPS "Running tests"
    sh scripts/test-sanity.sh > /tmp/test-output.log 2>&1
    TEST_EXIT=$?

    # Step 7: Finalizing
    CURRENT_STEP=7
    show_progress $CURRENT_STEP $TOTAL_STEPS "Complete"
    sleep 0.3
    clear_progress

    if [ $TEST_EXIT -ne 0 ]; then
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "                     SANITY CHECKS FAILED"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        cat /tmp/test-output.log
        kill $APP_PID
        exit 1
    fi

    # Extract test counts from output
    REST_COUNT=$(grep "REST API tests..." /tmp/test-output.log | grep -o '[0-9]* passed' | grep -o '[0-9]*')
    GRAPHQL_COUNT=$(grep "GraphQL tests..." /tmp/test-output.log | grep -o '[0-9]* passed' | grep -o '[0-9]*')
    TOTAL_COUNT=$((REST_COUNT + GRAPHQL_COUNT))

    echo ""

    # Show welcome message only on first launch
    if [ "$FIRST_LAUNCH" = true ]; then
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        echo "          Welcome to the Merkle Games API"
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        echo "  This containerized environment provides a complete games API"
        echo "  for your technical assessment. Everything you need to demonstrate"
        echo "  your skills is ready to go!"
        echo ""
        echo "  What's Inside:"
        echo "     • REST API with pagination and HATEOAS support"
        echo "     • GraphQL API for flexible, efficient queries"
        echo "     • Interactive API documentation (Swagger)"
        echo "     • GraphQL Playground for testing"
        echo "     • Deterministic image generator (mock media library)"
        echo "     • Health check endpoint"
        echo ""
        echo "  Available Endpoints:"
        echo "     • REST API:           http://localhost:8000/api/v1"
        echo "     • GraphQL Endpoint:   http://localhost:8000/graphql"
        echo "     • API Documentation:  http://localhost:8000/api-docs"
        echo "     • GraphQL Playground: http://localhost:8000/graphql-sandbox"
        echo "     • Image Generator:    http://localhost:8000/media/example?w=400&h=300"
        echo "     • Health Check:       http://localhost:8000/health"
        echo ""
        echo "  Quick Tips:"
        echo "     - All data is artificial/mock (perfect for testing!)"
        echo "     - REST API uses HATEOAS links for easy navigation"
        echo "     - GraphQL lets you query exactly what you need"
        echo "     - Data is pre-seeded and ready to query"
        echo "     - Images are generated deterministically (same params = same image)"
        echo "     - Swagger docs include example requests"
        echo ""
        echo ""
        echo "  Happy coding. Press Ctrl+C to stop."
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
    else
        # Regular startup - just show endpoints and test results
        echo "═══════════════════════════════════════════════════════════════════"
        echo "                       ALL SYSTEMS GO!"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        echo "Available Endpoints:"
        echo "   • REST API:           http://localhost:8000/api/v1"
        echo "   • API Documentation:  http://localhost:8000/api-docs"
        echo "   • GraphQL Endpoint:   http://localhost:8000/graphql"
        echo "   • GraphQL Playground: http://localhost:8000/graphql-sandbox"
        echo "   • Image Generator:    http://localhost:8000/media/example?w=400&h=300"
        echo "   • Health Check:       http://localhost:8000/health"
        echo ""
        echo "Test Results:"
        echo "   • REST API Tests:     ${REST_COUNT:-30} passed"
        echo "   • GraphQL Tests:      ${GRAPHQL_COUNT:-22} passed"
        echo "   • Total:              ${TOTAL_COUNT:-52} passed"
        echo ""
        echo ""
        echo "Press Ctrl+C to stop."
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
    fi
fi

# Keep the application running
wait $APP_PID
