<template>
  <div class="dashboard">
    <h1>Nuxt 4 Dashboard</h1>
    <p>Welcome to your web application.</p>

    <div class="card">
      <h2>Backend Users</h2>
      <div v-if="pending">Loading users...</div>
      <div v-else-if="error">Error loading users: {{ error.message }}</div>
      <ul v-else>
        <li v-for="user in users" :key="user.id">
          {{ user.name }} ({{ user.email }})
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
const config = useRuntimeConfig()
const apiBase = import.meta.server ? config.apiBaseInternal : config.public.apiBase
const { data: users, pending, error } = await useFetch(`${apiBase}/users`)
</script>

<style scoped>
.dashboard {
  font-family: system-ui, sans-serif;
  padding: 2rem;
  max-width: 800px;
  margin: 0 auto;
}
h1 { color: #00DC82; }
.card {
  background: #f1f5f9;
  padding: 1.5rem;
  border-radius: 8px;
  margin-top: 1rem;
}
ul { padding-left: 1.5rem; }
</style>
