<script lang="ts">
	import { onMount } from 'svelte';

	interface Video {
		id: number;
		title: string;
		description: string;
		thumbnail_url: string;
		video_url: string;
		views: number;
	}

	let videos = $state<Video[]>([]);
	let error = $state<string | null>(null);
	let isLoading = $state(true);

	onMount(async () => {
		try {
			const res = await fetch('http://localhost:4000/api/videos');
			if (!res.ok) {
				throw new Error('Network response was not ok');
			}
			const json = await res.json();
			videos = json.data || [];
		} catch (e: any) {
			error = e.message || 'Failed to fetch videos from the API';
		} finally {
			isLoading = false;
		}
	});

	// Formata views (ex: 12500 -> 12.5k)
	function formatViews(views: number): string {
		if (views >= 1000) {
			return (views / 1000).toFixed(1) + 'k';
		}
		return views.toString();
	}
</script>

<div class="min-h-screen bg-neutral-950 text-white font-sans relative overflow-hidden">
	<!-- Background glow effects -->
	<div class="absolute top-0 left-1/4 w-[600px] h-[600px] bg-purple-600/20 rounded-full blur-[150px] mix-blend-screen pointer-events-none"></div>
	<div class="absolute bottom-0 right-1/4 w-[500px] h-[500px] bg-blue-600/20 rounded-full blur-[150px] mix-blend-screen pointer-events-none"></div>

	<!-- Header Nav -->
	<nav class="fixed top-0 w-full z-50 bg-neutral-950/80 backdrop-blur-lg border-b border-white/10 px-8 py-4 flex items-center justify-between">
		<h1 class="text-3xl font-black tracking-tighter bg-gradient-to-r from-indigo-400 via-purple-400 to-pink-400 text-transparent bg-clip-text">
			Ondina
		</h1>
		<div class="flex items-center space-x-6">
			<button class="text-neutral-400 hover:text-white transition">Início</button>
			<button class="text-neutral-400 hover:text-white transition">Séries</button>
			<button class="text-neutral-400 hover:text-white transition">Filmes</button>
			<div class="w-8 h-8 rounded-full bg-gradient-to-tr from-purple-500 to-indigo-500 border-2 border-white/20"></div>
		</div>
	</nav>

	<main class="relative z-10 pt-32 pb-20 px-8 md:px-16 max-w-screen-2xl mx-auto space-y-12">
		
		<div class="space-y-2">
			<h2 class="text-3xl md:text-4xl font-bold tracking-tight">Em Alta</h2>
			<p class="text-neutral-400">Os conteúdos mais assistidos do momento.</p>
		</div>

		{#if isLoading}
			<div class="flex justify-center py-20">
				<div class="w-8 h-8 rounded-full border-4 border-purple-500 border-t-transparent animate-spin"></div>
			</div>
		{:else if error}
			<div class="backdrop-blur-md bg-red-500/10 border border-red-500/20 rounded-2xl p-8 text-center max-w-lg mx-auto">
				<div class="text-red-400 mb-2">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
				</div>
				<h3 class="text-lg font-semibold text-white">Oops, algo deu errado</h3>
				<p class="text-neutral-400 mt-2">{error}</p>
				<p class="text-xs text-neutral-500 mt-4">Certifique-se de que o backend Elixir está rodando.</p>
			</div>
		{:else}
			<!-- Grid Netflix/YouTube Style -->
			<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-6 md:gap-8">
				{#each videos as video}
					<!-- Video Card -->
					<div class="group flex flex-col space-y-3 cursor-pointer">
						<!-- Thumbnail Wrapper (Glassmorphism & Hover Zoom) -->
						<div class="relative overflow-hidden rounded-2xl aspect-video bg-neutral-900 border border-white/5 shadow-xl transition-all duration-300 group-hover:scale-[1.03] group-hover:shadow-2xl group-hover:border-white/20">
							<img 
								src={video.thumbnail_url} 
								alt={video.title}
								class="object-cover w-full h-full transition-transform duration-500 group-hover:scale-105"
							/>
							<!-- Overlay gradient for text readability if needed -->
							<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
							
							<!-- Play Button Overlay -->
							<div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
								<div class="w-12 h-12 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center border border-white/30 text-white">
									<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 ml-1" viewBox="0 0 20 20" fill="currentColor">
										<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
									</svg>
								</div>
							</div>
						</div>

						<!-- Info -->
						<div class="flex space-x-3 px-1">
							<!-- Channel Avatar Placeholder -->
							<div class="flex-shrink-0 w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 to-purple-500"></div>
							
							<div class="flex flex-col flex-grow overflow-hidden">
								<h3 class="text-white font-medium text-base leading-tight line-clamp-2 group-hover:text-purple-400 transition-colors">
									{video.title}
								</h3>
								<div class="text-neutral-400 text-sm mt-1 flex flex-col">
									<span class="line-clamp-1">{video.description}</span>
									<span class="text-neutral-500 text-xs mt-1">{formatViews(video.views)} visualizações • Agora</span>
								</div>
							</div>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</main>
</div>
