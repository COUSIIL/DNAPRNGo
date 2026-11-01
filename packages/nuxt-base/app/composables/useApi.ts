/**
 * Returns the API base URL: internal Docker URL on the server (SSR),
 * public URL in the browser.
 */
export const useApiBase = (): string => {
  const config = useRuntimeConfig()
  return import.meta.server ? config.apiBaseInternal : config.public.apiBase
}

