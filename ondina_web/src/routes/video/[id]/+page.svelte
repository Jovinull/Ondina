<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import type { PageData } from './$types';
	import { Socket } from 'phoenix';
	import { auth } from '$lib/stores/auth.svelte';

	export let data: PageData;
	const video = data.video;

	let views = $state(video.views);
	let justUpdated = $state(false);
	
	// Chat States
	let comments = $state<any[]>([]);
	let commentContent = $state('');
	let chatContainer: HTMLElement;

	let socket: Socket;
	let channel: any;

	onMount(async () => {
		// Estabelece a conexão WebSocket com o Phoenix
		socket = new Socket('ws://localhost:4000/socket', { params: { token: auth.token } });
		socket.connect();

		// Assina o canal de vídeo específico
		channel = socket.channel(`video:${video.id}`, {});
		
		channel.join()
			.receive('ok', (resp: any) => {
				console.log('Joined video channel successfully');
				comments = resp.comments || [];
				scrollToBottom();
			})
			.receive('error', (resp: any) => console.log('Unable to join', resp));

		// Escuta nova visualização
		channel.on('new_view', (payload: any) => {
			views = payload.views;
			justUpdated = true;
			setTimeout(() => { justUpdated = false; }, 600);
		});

		// Escuta novos comentários
		channel.on('new_comment', (payload: any) => {
			comments = [...comments, payload];
			scrollToBottom();
		});

		// Incrementa as visualizações (silencioso)
		try {
			await fetch(`http://localhost:4000/api/videos/${video.id}/view`, { method: 'POST' });
		} catch (e) {
			console.error('Failed to increment views:', e);
		}
	});

	onDestroy(() => {
		if (channel) channel.leave();
		if (socket) socket.disconnect();
	});

	function formatViews(v: number): string {
		if (v >= 1000) return (v / 1000).toFixed(1) + 'k';
		return v.toString();
	}

	function scrollToBottom() {
		setTimeout(() => {
			if (chatContainer) {
				chatContainer.scrollTo({
					top: chatContainer.scrollHeight,
					behavior: 'smooth'
				});
			}
		}, 100);
	}

	function submitComment(e: Event) {
		e.preventDefault();
		if (!auth.isAuthenticated || !commentContent.trim()) return;

		channel.push('new_comment', {
			content: commentContent
		});

		commentContent = ''; 
	}
</script>

<!-- Cinematic Mode Container -->
<div class="relative min-h-screen bg-black text-white overflow-hidden font-sans flex flex-col items-center">
	
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
	<nav class="absolute top-0 left-0 w-full z-50 p-6 flex justify-between items-center">
		<a href="/" class="inline-flex items-center space-x-2 text-white/70 hover:text-white transition-colors group backdrop-blur-md bg-black/20 px-4 py-2 rounded-full border border-white/10 hover:bg-white/10">
			<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 transform group-hover:-translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
			</svg>
			<span class="font-medium text-sm">Voltar ao Catálogo</span>
		</a>
		{#if auth.isAuthenticated}
			<div class="flex items-center space-x-4 bg-black/20 backdrop-blur-md px-4 py-2 rounded-full border border-white/10">
				<span class="text-sm text-white/80">Olá, <strong class="text-purple-400">{auth.user?.username}</strong></span>
				<button on:click={() => auth.logout()} class="text-xs text-white/50 hover:text-white transition-colors">Sair</button>
			</div>
		{:else}
			<a href="/login" class="text-sm font-medium text-white/80 hover:text-white bg-purple-600/80 hover:bg-purple-500 px-4 py-2 rounded-full transition-colors border border-purple-500/50">
				Fazer Login
			</a>
		{/if}
	</nav>

	<!-- Main Content Grid -->
	<main class="relative z-10 w-full max-w-[1400px] px-4 md:px-8 mt-24 mb-8 grid grid-cols-1 lg:grid-cols-4 gap-8">
		
		<!-- Esquerda: Player e Detalhes (Ocupa 3 colunas) -->
		<div class="lg:col-span-3 flex flex-col items-center">
			<!-- Video Player Wrapper -->
			<div class="relative w-full aspect-video bg-black/80 rounded-2xl shadow-2xl overflow-hidden border border-white/10 backdrop-blur-lg">
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
			<div class="w-full mt-8 flex flex-col md:flex-row md:items-start justify-between gap-6">
				<div class="flex-1 space-y-4">
					<h1 class="text-3xl md:text-4xl font-bold tracking-tight leading-tight">{video.title}</h1>
					
					<div class="flex items-center space-x-4 text-white/60 text-sm">
						<div class="flex items-center space-x-1.5">
							<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
							</svg>
							<span class="font-medium transition-all duration-300 {justUpdated ? 'text-green-400 scale-110 drop-shadow-[0_0_8px_rgba(74,222,128,0.8)]' : 'text-white'}">
								{formatViews(views)}
							</span>
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

				<!-- Interaction Buttons -->
				<div class="flex space-x-3 shrink-0">
					<button class="flex items-center space-x-2 bg-white/10 hover:bg-white/20 transition-colors backdrop-blur-md px-5 py-2.5 rounded-full border border-white/5">
						<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" />
						</svg>
						<span class="font-medium text-sm">Gostei</span>
					</button>
				</div>
			</div>
		</div>

		<!-- Direita: Chat em Tempo Real (Ocupa 1 coluna) -->
		<div class="lg:col-span-1 flex flex-col h-[600px] lg:h-auto lg:absolute lg:right-8 lg:w-[350px] lg:top-24 lg:bottom-8 bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl overflow-hidden shadow-2xl">
			
			<!-- Header Chat -->
			<div class="px-5 py-4 border-b border-white/10 bg-black/20">
				<h3 class="font-semibold text-white/90 flex items-center space-x-2">
					<span class="w-2 h-2 rounded-full bg-green-400 animate-pulse"></span>
					<span>Chat ao vivo</span>
				</h3>
			</div>

			<!-- Mensagens -->
			<div bind:this={chatContainer} class="flex-1 overflow-y-auto p-5 space-y-4 scroll-smooth">
				{#if comments.length === 0}
					<div class="text-center text-white/40 text-sm mt-10">
						Nenhuma mensagem ainda. Seja o primeiro!
					</div>
				{/if}

				{#each comments as comment (comment.id)}
					<div class="flex flex-col animate-fade-in">
						<span class="text-xs font-semibold text-purple-300 mb-0.5">{comment.author_name}</span>
						<span class="text-sm text-white/90 break-words">{comment.content}</span>
					</div>
				{/each}
			</div>

			<!-- Input Form -->
			<div class="p-4 bg-black/40 border-t border-white/10">
				{#if auth.isAuthenticated}
					<form on:submit={submitComment} class="flex space-x-2">
						<input 
							type="text" 
							bind:value={commentContent} 
							placeholder="Sua mensagem..." 
							required
							class="flex-1 bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-white placeholder-white/30 focus:outline-none focus:border-purple-500 transition-colors"
						/>
						<button 
							type="submit" 
							class="bg-purple-600 hover:bg-purple-500 text-white rounded-lg px-4 py-2 transition-colors flex items-center justify-center disabled:opacity-50"
							disabled={!commentContent.trim()}
						>
							<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
							</svg>
						</button>
					</form>
				{:else}
					<div class="text-center py-2">
						<p class="text-xs text-white/60 mb-2">Para participar do chat</p>
						<a href="/login" class="inline-block bg-purple-600 hover:bg-purple-500 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors">
							Faça Login
						</a>
					</div>
				{/if}
			</div>
		</div>

	</main>
</div>

<style>
	@keyframes fade-in {
		from { opacity: 0; transform: translateY(5px); }
		to { opacity: 1; transform: translateY(0); }
	}
	.animate-fade-in {
		animation: fade-in 0.3s ease-out forwards;
	}
</style>
