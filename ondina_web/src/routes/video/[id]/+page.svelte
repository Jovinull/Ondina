<script lang="ts">
	import { onMount } from 'svelte';
	import type { PageData } from './$types';

	export let data: PageData;
	const video = data.video;

	let views = $state(video.views);

	onMount(async () => {
		// Incrementa as visualizações
		try {
			const res = await fetch(`http://localhost:4000/api/videos/${video.id}/view`, {
				method: 'POST'
			});
			if (res.ok) {
				const json = await res.json();
				views = json.data.views;
			}
		} catch (e) {
			console.error('Failed to increment views:', e);
		}
	});

	function formatViews(v: number): string {
		if (v >= 1000) {
			return (v / 1000).toFixed(1) + 'k';
		}
		return v.toString();
	}
</script>

<!-- Cinematic Mode Container -->
<div class="relative min-h-screen bg-black text-white overflow-hidden font-sans flex flex-col items-center justify-center">
	
	<!-- Background Dinâmico -->
	<div class="absolute inset-0 z-0">
		<img 
			src={video.thumbnail_url} 
			alt="Background" 
			class="w-full h-full object-cover opacity-40 scale-110 blur-3xl transform-gpu"
		/>
		<div class="absolute inset-0 bg-gradient-to-t from-black via-black/50 to-transparent"></div>
	</div>

	<!-- Top Navigation -->
	<nav class="absolute top-0 left-0 w-full z-50 p-6">
		<a href="/" class="inline-flex items-center space-x-2 text-white/70 hover:text-white transition-colors group backdrop-blur-md bg-black/20 px-4 py-2 rounded-full border border-white/10 hover:bg-white/10">
			<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 transform group-hover:-translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
			</svg>
			<span class="font-medium text-sm">Voltar ao Catálogo</span>
		</a>
	</nav>

	<!-- Main Content: Player -->
	<main class="relative z-10 w-full max-w-6xl px-4 md:px-8 mt-16 mb-8 flex flex-col items-center">
		
		<!-- Video Player Wrapper -->
		<div class="relative w-full aspect-video bg-black/80 rounded-2xl shadow-2xl overflow-hidden border border-white/10 backdrop-blur-lg">
			<!-- HTML5 Video com controles customizados/nativos estilizados -->
			<video 
				src={video.video_url}
				poster={video.thumbnail_url}
				controls
				class="w-full h-full outline-none"
			>
				Seu navegador não suporta a tag de vídeo.
			</video>
		</div>

		<!-- Video Details -->
		<div class="w-full max-w-5xl mt-8 flex flex-col md:flex-row md:items-start justify-between gap-6">
			<div class="flex-1 space-y-4">
				<h1 class="text-3xl md:text-4xl font-bold tracking-tight leading-tight">{video.title}</h1>
				
				<div class="flex items-center space-x-4 text-white/60 text-sm">
					<div class="flex items-center space-x-1.5">
						<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
						</svg>
						<span class="font-medium text-white">{formatViews(views)}</span>
						<span>visualizações</span>
					</div>
					<span>•</span>
					<span>Agora mesmo</span>
				</div>

				<div class="bg-white/5 backdrop-blur-md border border-white/10 rounded-xl p-6 mt-4">
					<p class="text-white/80 leading-relaxed text-sm md:text-base">
						{video.description}
					</p>
				</div>
			</div>

			<!-- Interaction Buttons (Like / Share placeholder) -->
			<div class="flex space-x-3 shrink-0">
				<button class="flex items-center space-x-2 bg-white/10 hover:bg-white/20 transition-colors backdrop-blur-md px-5 py-2.5 rounded-full border border-white/5">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" />
					</svg>
					<span class="font-medium text-sm">Gostei</span>
				</button>
				<button class="flex items-center space-x-2 bg-white/10 hover:bg-white/20 transition-colors backdrop-blur-md px-5 py-2.5 rounded-full border border-white/5">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
					</svg>
					<span class="font-medium text-sm">Partilhar</span>
				</button>
			</div>
		</div>
	</main>
</div>
