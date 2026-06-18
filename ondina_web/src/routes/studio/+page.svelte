<script lang="ts">
	import { auth } from '$lib/stores/auth.svelte';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	let videos = $state<any[]>([]);
	let loading = $state(true);
	let errorMsg = $state('');

	let analyticsData = $state<any>(null);
	let loadingAnalytics = $state(true);

	let engagementRate = $derived(() => {
		if (!analyticsData) return 0;
		const { total_likes, total_dislikes, total_views } = analyticsData.stats;
		if (total_views === 0) return 0;
		return (((total_likes + total_dislikes) / total_views) * 100).toFixed(1);
	});

	// Modal States
	let isModalOpen = $state(false);
	let videoToDelete = $state<any>(null);
	let isDeleting = $state(false);

	onMount(() => {
		if (auth.isInitialized && !auth.isAuthenticated) {
			goto('/login');
		} else if (auth.isAuthenticated) {
			fetchMyVideos();
			fetchAnalytics();
		}
	});

	$effect(() => {
		if (auth.isInitialized && !auth.isAuthenticated) {
			goto('/login');
		}
	});

	async function fetchMyVideos() {
		try {
			const res = await fetch('http://localhost:4000/api/me/videos', {
				headers: { 'Authorization': `Bearer ${auth.token}` }
			});
			if (res.ok) {
				const data = await res.json();
				videos = data.data;
			} else {
				errorMsg = 'Falha ao carregar vídeos.';
			}
		} catch (e) {
			errorMsg = 'Erro de conexão com o servidor.';
		} finally {
			loading = false;
		}
	}

	async function fetchAnalytics() {
		try {
			const res = await fetch('http://localhost:4000/api/me/analytics', {
				headers: { 'Authorization': `Bearer ${auth.token}` }
			});
			if (res.ok) {
				const data = await res.json();
				analyticsData = data.data;
			}
		} catch (e) {
			console.error('Falha ao carregar analytics');
		} finally {
			loadingAnalytics = false;
		}
	}

	function confirmDelete(video: any) {
		videoToDelete = video;
		isModalOpen = true;
	}

	function closeModal() {
		isModalOpen = false;
		videoToDelete = null;
	}

	async function executeDelete() {
		if (!videoToDelete) return;
		isDeleting = true;

		try {
			const res = await fetch(`http://localhost:4000/api/videos/${videoToDelete.id}`, {
				method: 'DELETE',
				headers: { 'Authorization': `Bearer ${auth.token}` }
			});

			if (res.ok || res.status === 204) {
				videos = videos.filter(v => v.id !== videoToDelete.id);
				closeModal();
			} else {
				const data = await res.json();
				alert(data.error || 'Erro ao deletar vídeo.');
			}
		} catch (e) {
			alert('Erro de conexão ao deletar.');
		} finally {
			isDeleting = false;
		}
	}
</script>

<div class="min-h-[calc(100vh-5rem)] bg-black text-white relative font-sans p-6 md:p-12 overflow-hidden">
	
	<!-- Background Aesthetics -->
	<div class="absolute inset-0 z-0 pointer-events-none">
		<div class="absolute top-[10%] right-[10%] w-[40%] h-[40%] bg-purple-900/20 rounded-full blur-[150px]"></div>
	</div>

	<main class="relative z-10 w-full max-w-[1200px] mx-auto bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl shadow-2xl overflow-hidden flex flex-col h-[80vh]">
		
		<!-- Header Studio -->
		<div class="px-8 py-6 border-b border-white/10 flex justify-between items-center bg-black/40">
			<div>
				<h1 class="text-2xl font-bold tracking-tight">Ondina Studio</h1>
				<p class="text-white/50 text-sm mt-1">Gerencie seu conteúdo e estatísticas</p>
			</div>
			<a href="/upload" class="bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white font-medium py-2 px-6 rounded-full transition-all shadow-[0_0_15px_rgba(147,51,234,0.3)]">
				Novo Vídeo
			</a>
		</div>

		<!-- Analytics Dashboard -->
		<div class="px-8 pt-6">
			{#if loadingAnalytics}
				<div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
					{#each Array(4) as _}
						<div class="backdrop-blur-xl bg-white/5 border border-white/10 p-6 rounded-2xl h-28 animate-pulse flex items-center">
							<div class="w-12 h-12 rounded-xl bg-white/10"></div>
							<div class="ml-4 space-y-2 flex-1">
								<div class="h-3 bg-white/10 rounded w-1/2"></div>
								<div class="h-6 bg-white/10 rounded w-3/4"></div>
							</div>
						</div>
					{/each}
				</div>
			{:else if analyticsData}
				<div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
					<!-- Total de Visualizações -->
					<div class="backdrop-blur-xl bg-white/5 border border-white/10 p-6 rounded-2xl relative overflow-hidden group">
						<div class="absolute inset-0 bg-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
						<div class="relative z-10 flex items-center">
							<div class="p-3 bg-purple-500/20 rounded-xl text-purple-400">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
								</svg>
							</div>
							<div class="ml-4">
								<p class="text-white/50 text-xs font-medium uppercase tracking-wider mb-1">Visualizações</p>
								<p class="text-2xl font-bold text-white drop-shadow-[0_0_10px_rgba(168,85,247,0.5)]">{analyticsData.stats.total_views}</p>
							</div>
						</div>
					</div>

					<!-- Total de Gostos -->
					<div class="backdrop-blur-xl bg-white/5 border border-white/10 p-6 rounded-2xl relative overflow-hidden group">
						<div class="absolute inset-0 bg-green-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
						<div class="relative z-10 flex items-center">
							<div class="p-3 bg-green-500/20 rounded-xl text-green-400">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" />
								</svg>
							</div>
							<div class="ml-4">
								<p class="text-white/50 text-xs font-medium uppercase tracking-wider mb-1">Gostos (Likes)</p>
								<p class="text-2xl font-bold text-white drop-shadow-[0_0_10px_rgba(34,197,94,0.3)]">{analyticsData.stats.total_likes}</p>
							</div>
						</div>
					</div>

					<!-- Engajamento -->
					<div class="backdrop-blur-xl bg-white/5 border border-white/10 p-6 rounded-2xl relative overflow-hidden group">
						<div class="absolute inset-0 bg-pink-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
						<div class="relative z-10 flex items-center">
							<div class="p-3 bg-pink-500/20 rounded-xl text-pink-400">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
								</svg>
							</div>
							<div class="ml-4">
								<p class="text-white/50 text-xs font-medium uppercase tracking-wider mb-1">Engajamento</p>
								<p class="text-2xl font-bold text-white drop-shadow-[0_0_10px_rgba(236,72,153,0.3)]">{engagementRate()}%</p>
							</div>
						</div>
					</div>

					<!-- Vídeos Ativos -->
					<div class="backdrop-blur-xl bg-white/5 border border-white/10 p-6 rounded-2xl relative overflow-hidden group">
						<div class="absolute inset-0 bg-blue-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
						<div class="relative z-10 flex items-center">
							<div class="p-3 bg-blue-500/20 rounded-xl text-blue-400">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 4v16M17 4v16M3 8h4m10 0h4M3 12h18M3 16h4m10 0h4M4 20h16a1 1 0 001-1V5a1 1 0 00-1-1H4a1 1 0 00-1 1v14a1 1 0 001 1z" />
								</svg>
							</div>
							<div class="ml-4">
								<p class="text-white/50 text-xs font-medium uppercase tracking-wider mb-1">Vídeos Ativos</p>
								<p class="text-2xl font-bold text-white drop-shadow-[0_0_10px_rgba(59,130,246,0.3)]">{analyticsData.stats.total_videos}</p>
							</div>
						</div>
					</div>
				</div>

				<!-- Top Videos -->
				{#if analyticsData.top_videos.length > 0}
					<div class="mb-8 backdrop-blur-xl bg-white/5 border border-white/10 rounded-2xl p-6">
						<h3 class="text-lg font-bold text-white mb-4">Publicações em Destaque</h3>
						<div class="flex flex-col space-y-4">
							{#each analyticsData.top_videos as topVid}
								<div class="flex items-center space-x-4 bg-black/40 rounded-xl p-3 border border-white/5">
									<div class="w-20 h-12 bg-black/50 rounded-lg overflow-hidden shrink-0 border border-white/10 relative">
										<img src={topVid.thumbnail_url} alt="Capa" class="w-full h-full object-cover opacity-80" />
									</div>
									<div class="flex-1 min-w-0">
										<p class="font-medium text-white/90 truncate text-sm">{topVid.title}</p>
										<div class="flex items-center mt-1">
											<div class="h-1.5 bg-white/10 rounded-full flex-1 overflow-hidden">
												<div class="h-full bg-gradient-to-r from-purple-500 to-pink-500" style="width: {analyticsData.stats.total_views > 0 ? (topVid.views / analyticsData.stats.total_views) * 100 : 0}%"></div>
											</div>
											<span class="ml-3 text-xs text-white/50 w-16 text-right">{topVid.views} views</span>
										</div>
									</div>
									<a href={`/video/${topVid.id}`} class="p-2 text-white/40 hover:text-purple-400 hover:bg-purple-400/10 rounded-lg transition-colors">
										<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
										</svg>
									</a>
								</div>
							{/each}
						</div>
					</div>
				{/if}
			{/if}
		</div>

		<!-- Lista de Vídeos -->
		<div class="flex-1 overflow-y-auto p-8">
			{#if loading}
				<div class="flex justify-center items-center h-full">
					<div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-purple-500"></div>
				</div>
			{:else if errorMsg}
				<div class="text-center text-red-400 p-8">{errorMsg}</div>
			{:else if videos.length === 0}
				<div class="flex flex-col justify-center items-center h-full text-white/50 space-y-4">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 opacity-50" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
					</svg>
					<p>Você ainda não postou nenhum vídeo.</p>
				</div>
			{:else}
				<div class="overflow-x-auto">
					<table class="w-full text-left border-collapse">
						<thead>
							<tr class="text-sm font-medium text-white/40 border-b border-white/5">
								<th class="pb-4 pl-2">Vídeo</th>
								<th class="pb-4 text-right">Views</th>
								<th class="pb-4 text-right">Likes</th>
								<th class="pb-4 text-right">Dislikes</th>
								<th class="pb-4 text-right pr-2">Ações</th>
							</tr>
						</thead>
						<tbody class="divide-y divide-white/5">
							{#each videos as video}
								<tr class="hover:bg-white/5 transition-colors group">
									<td class="py-4 pl-2 flex items-center space-x-4">
										<div class="w-24 h-14 bg-black/50 rounded-lg overflow-hidden shrink-0 border border-white/10 relative">
											<img src={video.thumbnail_url} alt="Capa" class="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity" />
										</div>
										<div>
											<p class="font-medium text-white/90 line-clamp-1">{video.title}</p>
											<a href={`/video/${video.id}`} class="text-xs text-purple-400 hover:text-purple-300 mt-1 inline-block">Ver na plataforma</a>
										</div>
									</td>
									<td class="py-4 text-right text-sm text-white/70">{video.views}</td>
									<td class="py-4 text-right text-sm text-green-400/80">{video.likes_count}</td>
									<td class="py-4 text-right text-sm text-red-400/80">{video.dislikes_count}</td>
									<td class="py-4 text-right pr-2">
										<button 
											on:click={() => confirmDelete(video)}
											class="p-2 text-white/40 hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-colors inline-flex"
											title="Excluir Vídeo"
										>
											<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
											</svg>
										</button>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{/if}
		</div>
	</main>
</div>

<!-- Modal de Confirmação Absoluto -->
{#if isModalOpen}
	<div class="fixed inset-0 z-[200] flex items-center justify-center p-4">
		<!-- Backdrop -->
		<div class="absolute inset-0 bg-black/60 backdrop-blur-sm" on:click={closeModal}></div>
		
		<!-- Dialog -->
		<div class="relative bg-[#111] border border-white/10 rounded-2xl shadow-2xl p-6 w-full max-w-md animate-in fade-in zoom-in-95 duration-200">
			<h2 class="text-xl font-bold text-white mb-2">Excluir Vídeo?</h2>
			<p class="text-white/60 text-sm mb-6">
				Tem certeza que deseja excluir o vídeo <strong class="text-white">"{videoToDelete?.title}"</strong>? 
				Esta ação removerá o arquivo permanentemente do servidor e não pode ser desfeita.
			</p>
			
			<div class="flex justify-end space-x-3">
				<button 
					on:click={closeModal}
					disabled={isDeleting}
					class="px-4 py-2 rounded-lg text-sm font-medium text-white/70 hover:text-white hover:bg-white/10 transition-colors"
				>
					Cancelar
				</button>
				<button 
					on:click={executeDelete}
					disabled={isDeleting}
					class="px-4 py-2 rounded-lg text-sm font-medium bg-red-500/80 hover:bg-red-500 text-white transition-colors flex items-center shadow-[0_0_15px_rgba(239,68,68,0.3)] disabled:opacity-50"
				>
					{#if isDeleting}
						<svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
							<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
							<path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
						</svg>
						Excluindo...
					{:else}
						Sim, Excluir
					{/if}
				</button>
			</div>
		</div>
	</div>
{/if}
