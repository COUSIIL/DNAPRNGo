<template>
  <main class="page">
    <h1>Nuxt App</h1>
    <p>Welcome to your web application.</p>

    <section class="card">
      <h2>Backend Users</h2>
      <p v-if="status === 'pending'">Loading users...</p>
      <p v-else-if="error">Error loading users: {{ error.message }}</p>
      <p v-else-if="!users?.length">No users yet.</p>
      <ul v-else>
        <li v-for="user in users" :key="user.id">{{ user.name }} ({{ user.email }})</li>
      </ul>
    </section>
  </main>
</template>

<script setup lang="ts">
interface User { id: number; name: string; email: string }

const apiBase = useApiBase()
const { data: users, status, error } = await useFetch<User[]>(`${apiBase}/users`, { key: 'users' })
</script>

<style scoped>
.page { font-family: system-ui, sans-serif; padding: 2rem; max-width: 800px; margin: 0 auto; }
h1 { color: #00DC82; }
.card { background: #f1f5f9; padding: 1.5rem; border-radius: 8px; margin-top: 1rem; }
ul { padding-left: 1.5rem; }
</style>
