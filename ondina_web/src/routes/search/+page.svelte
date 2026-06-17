<script lang="ts">
	import { page } from '$app/stores';
	
	let videos = $state<any[]>([]);
	let loading = $state(false);
	let errorMsg = $state('');
	
	let currentQuery = $state('');

	$effect(() => {
		const q = $page.url.searchParams.get('q');
		if (q && q !== currentQuery) {
			currentQuery = q;
			fetchResults(q);
		}
	});

	async function fetchResults(query: string) {
		loading = true;
		errorMsg = '';
		
		try {
			const res = await fetch(`http://localhost:4000/api/videos/search?q=${encodeURIComponent(query)}`);
			if (res.ok) {
				const data = await res.json();
				videos = data.data;
			} else {
				errorMsg = 'Erro ao buscar resultados.';
			}
		} catch (e) {
			errorMsg = 'Erro de conexão ao buscar.';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Busca: {currentQuery} - Ondina</title>
</svelte:head>

<div class="min-h-screen bg-black text-white relative font-sans p-6 md:p-12 overflow-hidden pt-28">
	<!-- Background Aesthetics -->
	<div class="absolute inset-0 z-0 pointer-events-none">
		<div class="absolute top-0 right-[20%] w-[50%] h-[50%] bg-blue-900/10 rounded-full blur-[150px]"></div>
		<div class="absolute bottom-[10%] left-[10%] w-[40%] h-[40%] bg-purple-900/10 rounded-full blur-[150px]"></div>
	</div>

	<main class="relative z-10 max-w-[1400px] mx-auto">
		<div class="mb-10">
			<h1 class="text-3xl font-bold text-white tracking-tight flex items-center space-x-3">
				<span class="text-white/40 font-normal">Resultados para:</span>
				<span class="text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-400">"{currentQuery}"</span>
			</h1>
		</div>

		{#if loading}
			<div class="flex flex-col items-center justify-center py-20 space-y-4">
				<div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-purple-500"></div>
				<p class="text-white/50 text-sm">Pesquisando no catálogo...</p>
			</div>
		{:else if errorMsg}
			<div class="text-center text-red-400 py-20 bg-red-500/10 rounded-2xl border border-red-500/20">{errorMsg}</div>
		{:else if videos.length === 0}
			<div class="flex flex-col items-center justify-center py-20 bg-white/5 backdrop-blur-md rounded-3xl border border-white/10">
				<svg xmlns="http://www.w3.org/2000/svg" class="h-20 w-20 text-white/20 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
				</svg>
				<h2 class="text-xl font-medium text-white/80">Nenhum vídeo encontrado</h2>
				<p class="text-white/40 mt-2 text-sm max-w-sm text-center">Tente buscar por outras palavras-chave ou explorar nosso catálogo principal.</p>
			</div>
		{:else}
			<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
				{#each videos as video}
					<a href={`/video/${video.id}`} class="group relative bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl overflow-hidden hover:bg-white/10 transition-all hover:-translate-y-1 hover:shadow-2xl hover:shadow-purple-500/20 block cursor-pointer">
						<div class="aspect-video bg-black/50 overflow-hidden relative">
							<img src={video.thumbnail_url} alt={video.title} class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 ease-out" />
							<div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-60 group-hover:opacity-80 transition-opacity"></div>
						</div>
						<div class="p-5">
							<h3 class="text-lg font-bold text-white/90 group-hover:text-white line-clamp-2 leading-tight transition-colors">{video.title}</h3>
							<div class="mt-4 flex items-center justify-between">
								<div class="flex items-center space-x-2">
									<div class="w-6 h-6 rounded-full bg-gradient-to-tr from-purple-500 to-pink-500 flex items-center justify-center text-[10px] font-bold text-white shadow-inner">
										{video.user_name.charAt(0).toUpperCase()}
									</div>
									<span class="text-sm font-medium text-white/60 group-hover:text-white/80 transition-colors">{video.user_name}</span>
								</div>
								<div class="flex items-center text-white/40 text-xs font-medium space-x-1">
									<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
									</svg>
									<span>{video.views}</span>
								</div>
							</div>
						</div>
					</a>
				{/each}
			</div>
		{/if}
	</main>
</div>
