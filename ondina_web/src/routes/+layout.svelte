<script lang="ts">
	import '../app.css';
	import { auth } from '$lib/stores/auth.svelte';
	import { onMount } from 'svelte';

	onMount(() => {
		auth.init();
	});
</script>

<slot />
