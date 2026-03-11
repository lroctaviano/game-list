<template>
    <nav class="header">
        <NuxtLink v-if="$route.path !== '/'" :to="`/`" class="back"> 
            ← Back
        </NuxtLink>
        <h1 class="header-title">List of Games</h1>
    </nav>
</template>