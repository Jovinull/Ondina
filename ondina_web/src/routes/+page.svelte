<script lang="ts">
	import { onMount } from 'svelte';

	let apiStatus = $state<{ status: string; message: string } | null>(null);
	let error = $state<string | null>(null);
	let isLoading = $state(true);

	onMount(async () => {
		try {
			const res = await fetch('http://localhost:4000/api/status');
			if (!res.ok) {
				throw new Error('Network response was not ok');
			}
			apiStatus = await res.json();
		} catch (e: any) {
			error = e.message || 'Failed to connect to the API';
		} finally {
			isLoading = false;
		}
	});
</script>

<div class="min-h-screen bg-neutral-950 text-white flex flex-col items-center justify-center font-sans relative overflow-hidden">
	<!-- Background glow effects -->
	<div class="absolute top-1/4 left-1/4 w-[500px] h-[500px] bg-purple-600/30 rounded-full blur-[120px] mix-blend-screen pointer-events-none"></div>
	<div class="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] bg-blue-600/30 rounded-full blur-[100px] mix-blend-screen pointer-events-none"></div>

	<main class="z-10 flex flex-col items-center space-y-12">
		<!-- Branding -->
		<div class="text-center space-y-4">
			<h1 class="text-6xl md:text-8xl font-black tracking-tighter bg-gradient-to-r from-indigo-400 via-purple-400 to-pink-400 text-transparent bg-clip-text animate-pulse">
				Ondina
			</h1>
			<p class="text-neutral-400 text-xl tracking-wide font-light max-w-md mx-auto">
				Reinventando a experiência de streaming.
			</p>
		</div>

		<!-- Status Card (Glassmorphism) -->
		<div class="backdrop-blur-xl bg-white/5 border border-white/10 rounded-3xl p-8 max-w-sm w-full shadow-2xl transition-all hover:bg-white/10">
			<h2 class="text-sm uppercase tracking-widest text-neutral-500 mb-6 font-semibold">
				System Status
			</h2>
			
			<div class="flex items-center space-x-4">
				{#if isLoading}
					<div class="w-4 h-4 rounded-full border-2 border-neutral-500 border-t-transparent animate-spin"></div>
					<span class="text-neutral-400">Verificando backend...</span>
				{:else if error}
					<div class="w-4 h-4 rounded-full bg-red-500 shadow-[0_0_15px_rgba(239,68,68,0.5)] animate-pulse"></div>
					<div class="flex flex-col">
						<span class="text-red-400 font-medium">API Indisponível</span>
						<span class="text-xs text-neutral-500 mt-1">Siga as instruções do README para iniciar o servidor Elixir.</span>
					</div>
				{:else if apiStatus}
					<div class="w-4 h-4 rounded-full bg-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.5)]"></div>
					<div class="flex flex-col">
						<span class="text-emerald-400 font-medium">Conectado</span>
						<span class="text-xs text-neutral-400 mt-1">{apiStatus.message}</span>
					</div>
				{/if}
			</div>
		</div>
	</main>
</div>
