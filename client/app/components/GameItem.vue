<script setup>
    const props = defineProps(['gameId', 'title', 'description', 'genre', 'release_date', 'developer', 'publisher', 'platform', 'images']);
    const status = await useFetch(`http://localhost:8000/api/v1/games/${props.gameId}/stats`)
    const ratingData = status.data;
    const coverImage = props.images?.filter(item => { return item.image_type === 'Cover'} )[0]    
</script>

<template>
    <div class="game-item">
        <div class="game-item-thumbnail">
            <img :src="`http://localhost:8000` +  coverImage.image_url" />
        </div>
        <div class="game-item-details">
            <h2>{{ title }}</h2>
            <p>{{description}}</p>
            <p>Genre: {{ genre.name }}</p>
            <p>Release Date: {{ release_date }}</p>
            <p>Developer: {{ developer.name }}</p>
            <p>Platform: {{ platform }}</p>
            <p>Rating: {{ ratingData.data.average_rating.toFixed(2) }}</p>
        </div>
        <NuxtLink class="game-item-button" :to="`/game/${props.gameId}/`">See Game Details</NuxtLink>
    </div>
</template>