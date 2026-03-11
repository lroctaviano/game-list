<script setup>
    const route = useRoute()
    const getGameDetails = await useFetch(`http://localhost:8000/api/v1/games/${route.params.id}`)
    const gameDetails = getGameDetails.data
    const status = await useFetch(`http://localhost:8000/api/v1/games/${route.params.id}/stats`)
    const ratingData = status.data;
</script>

<template>
    <div class="game-details">
        <div class="game-image">
            <img :src="`http://localhost:8000` + gameDetails.data?.images?.filter(item => { return item.image_type === 'Artwork'} )[0].image_url" />
        </div>
        <div class="game-header">
            <h2>{{ gameDetails.data.title }}</h2>
            <p>{{ gameDetails.data.description }}</p>
        </div>
        <hr>
        <div class="game-info">
            <h3>Game info:</h3>
            <p>Release Date: {{ gameDetails.data.release_date }}</p>
            <p>Developer: {{ gameDetails.data.developer.name }}</p>
            <p>Genre: {{ gameDetails.data.genre.name }}</p>
            <p>Rating: {{ ratingData.data.average_rating.toFixed(2) }}</p>
        </div>
        <hr>
        <div class="game-reviews">
            <h3>Reviews:</h3>
            <div class="game-review" v-for="review in gameDetails.data.reviews">
                <h4>Name: {{ review.user.username }}</h4>
                <p>Rating: {{ review.rating.toFixed(2) }}</p>
                <p>Comment: {{ review.review_text }}</p>
            </div>
        </div>
    </div>
</template>