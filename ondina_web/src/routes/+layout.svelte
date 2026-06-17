<script lang="ts">
	import '../app.css';
	import { auth } from '$lib/stores/auth.svelte';
	import { onMount } from 'svelte';

	import Header from '$lib/components/Header.svelte';

	onMount(() => {
		auth.init();
	});
</script>

<Header />

<div class="pt-20 min-h-screen">
	<slot />
</div>
