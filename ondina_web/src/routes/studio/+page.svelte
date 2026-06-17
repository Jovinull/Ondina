<script lang="ts">
	import { auth } from '$lib/stores/auth.svelte';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	let videos = $state<any[]>([]);
	let loading = $state(true);
	let errorMsg = $state('');

	// Modal States
	let isModalOpen = $state(false);
	let videoToDelete = $state<any>(null);
	let isDeleting = $state(false);

	onMount(() => {
		if (auth.isInitialized && !auth.isAuthenticated) {
			goto('/login');
		} else if (auth.isAuthenticated) {
			fetchMyVideos();
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
