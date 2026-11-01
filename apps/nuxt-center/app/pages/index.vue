<template>
  <main class="page">
    <h1>Nuxt Center</h1>
    <p>Administration &amp; monitoring hub.</p>

    <section class="card">
      <h2>Service health</h2>
      <p v-if="status === 'pending'">Checking services...</p>
      <p v-else-if="error">API unreachable: {{ error.message }}</p>
      <ul v-else-if="health">
        <li>API: {{ health.status }}</li>
        <li>PostgreSQL: {{ health.postgres }}</li>
        <li>Redis: {{ health.redis }}</li>
      </ul>
      <button @click="() => refresh()">Refresh</button>
    </section>
  </main>
</template>

<script setup lang="ts">
interface Health { status: string; postgres: string; redis: string }

const apiBase = useApiBase()
const { data: health, status, error, refresh } = await useFetch<Health>(`${apiBase}/health`, { key: 'health' })
</script>

<style scoped>
.page { font-family: system-ui, sans-serif; padding: 2rem; max-width: 800px; margin: 0 auto; }
h1 { color: #2563eb; }
.card { background: #f1f5f9; padding: 1.5rem; border-radius: 8px; margin-top: 1rem; }
ul { padding-left: 1.5rem; }
</style>
