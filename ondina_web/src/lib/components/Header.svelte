<script lang="ts">
	import { auth } from '$lib/stores/auth.svelte';
	import { goto } from '$app/navigation';
</script>

<header class="fixed top-0 left-0 w-full z-[100] backdrop-blur-md bg-black/40 border-b border-white/10 transition-colors">
	<div class="max-w-[1400px] mx-auto px-6 h-20 flex items-center justify-between">
		
		<!-- Logo -->
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

		<!-- Auth Nav -->
		<nav>
			{#if auth.isAuthenticated}
				<div class="flex items-center space-x-4">
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
