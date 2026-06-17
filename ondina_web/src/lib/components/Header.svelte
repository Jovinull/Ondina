<script lang="ts">
	import { auth } from '$lib/stores/auth.svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	let searchQuery = $state('');
	let timeoutId: any;

	$effect(() => {
		const q = $page.url.searchParams.get('q');
		if (q && q !== searchQuery) {
			searchQuery = q;
		} else if (!q && $page.url.pathname !== '/search') {
			searchQuery = '';
		}
	});

	function handleInput() {
		if (timeoutId) clearTimeout(timeoutId);
		timeoutId = setTimeout(() => {
			if (searchQuery.trim()) {
				goto(`/search?q=${encodeURIComponent(searchQuery)}`);
			} else if ($page.url.pathname === '/search') {
				goto(`/`);
			}
		}, 500);
	}
</script>

<header class="fixed top-0 left-0 w-full z-[100] backdrop-blur-md bg-black/40 border-b border-white/10 transition-colors">
	<div class="max-w-[1400px] mx-auto px-6 h-20 flex items-center justify-between">
		
		<!-- Lado Esquerdo: Logo e Busca -->
		<div class="flex items-center space-x-8 flex-1">
			<a href="/" class="flex items-center space-x-2 group">
				<div class="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center shadow-lg group-hover:scale-105 transition-transform">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" viewBox="0 0 20 20" fill="currentColor">
						<path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z" />
					</svg>
				</div>
				<span class="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-white to-white/70 tracking-tight">
					Ondina
				</span>
			</a>
			
			<div class="hidden md:flex flex-1 max-w-md relative">
				<div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
					<svg class="h-4 w-4 text-white/40" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
					</svg>
				</div>
				<input 
					type="text" 
					bind:value={searchQuery}
					on:input={handleInput}
					placeholder="Pesquisar..."
					class="w-full bg-white/5 border border-white/10 rounded-full py-2 pl-10 pr-4 text-sm text-white placeholder-white/40 focus:outline-none focus:ring-1 focus:ring-purple-500/50 transition-all backdrop-blur-md"
				/>
			</div>
		</div>		<!-- Auth Nav -->
		<nav>
			{#if auth.isAuthenticated}
				<div class="flex items-center space-x-4">
					<a href="/studio" class="hidden md:flex items-center space-x-2 text-sm font-medium text-white bg-white/10 hover:bg-white/20 transition-colors px-4 py-2 rounded-full border border-white/5">
						<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 002-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
						</svg>
						<span>Studio</span>
					</a>
					<a href="/upload" class="hidden md:flex items-center space-x-2 text-sm font-medium text-white bg-white/10 hover:bg-white/20 transition-colors px-4 py-2 rounded-full border border-white/5">
						<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
						</svg>
						<span>Novo Vídeo</span>
					</a>
					<div class="flex items-center space-x-3 bg-white/5 backdrop-blur-md px-4 py-2 rounded-full border border-white/10">
						<div class="w-8 h-8 rounded-full bg-gradient-to-tr from-purple-500 to-pink-500 flex items-center justify-center text-sm font-bold shadow-inner">
							{auth.user?.username.charAt(0).toUpperCase()}
						</div>
						<span class="text-sm font-medium text-white/90">{auth.user?.username}</span>
					</div>
					<button 
						on:click={() => auth.logout()} 
						class="text-sm text-white/60 hover:text-red-400 transition-colors font-medium px-2"
					>
						Sair
					</button>
				</div>
			{:else}
				<div class="flex items-center space-x-4">
					<a href="/login" class="text-sm font-medium text-white/70 hover:text-white transition-colors">
						Entrar
					</a>
					<a href="/register" class="text-sm font-medium text-white bg-purple-600 hover:bg-purple-500 px-5 py-2.5 rounded-full shadow-[0_0_15px_rgba(147,51,234,0.3)] transition-all hover:scale-105">
						Cadastrar-se
					</a>
				</div>
			{/if}
		</nav>

	</div>
</header>
