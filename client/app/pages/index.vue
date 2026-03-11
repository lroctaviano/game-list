<script setup lang="ts">
    const sortType = ref<string>('topRated')
    interface Game {
        id: number;
        title: string;
        description: string;
        release_date: string;
        publisher: object;
        developer: object;
        genre: object;
        images: Array<[]>;
        platform: string;
        data: any;
    }

    const games = await useFetch<Game[]>('http://localhost:8000/api/v1/games')
</script>
<template>
    <section class="sort-button">
        <h2>Sort By:</h2>
        <select v-model="sortType">
            <option disabled value="">Please select one</option>
            <option value="topRated">Top Rated</option>
            <option value="releaseDate">Release Date</option>
        </select>
    </section>
    <section class="game-list">
        <GameItem 
            v-for="game in games.data.value?.data"
            :key="game.id"
            :game-id="game.id"
            :title="game.title"
            :description="game.description"
            :release_date="game.release_date"
            :publisher="game.publisher"
            :developer="game.developer"
            :genre="game.genre"
            :images="game.images"
            :platform="game.platform"
        />
    </section>
</template>
