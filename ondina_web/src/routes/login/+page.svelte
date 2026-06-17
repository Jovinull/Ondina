<script lang="ts">
	import { auth } from '$lib/stores/auth.svelte';
	import { goto } from '$app/navigation';

	let email = $state('');
	let password = $state('');
	let errorMsg = $state('');
	let loading = $state(false);

	async function handleLogin(e: Event) {
		e.preventDefault();
		loading = true;
		errorMsg = '';

		try {
			const res = await fetch('http://localhost:4000/api/login', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ email, password })
			});

			if (res.ok) {
				const data = await res.json();
				auth.login(data.token, data.user);
				goto('/');
			} else {
				const data = await res.json();
				errorMsg = data.error || 'Credenciais inválidas.';
			}
		} catch (err) {
			errorMsg = 'Erro na comunicação com o servidor.';
		} finally {
			loading = false;
		}
	}
</script>

<div class="min-h-screen flex items-center justify-center bg-black relative font-sans">
	
	<!-- Background Blur Aesthetics -->
	<div class="absolute inset-0 z-0 overflow-hidden">
		<div class="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-purple-900/30 rounded-full blur-[120px]"></div>
		<div class="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] bg-blue-900/30 rounded-full blur-[120px]"></div>
	</div>

	<main class="relative z-10 w-full max-w-md p-8 bg-white/5 backdrop-blur-2xl border border-white/10 rounded-3xl shadow-2xl">
		<div class="text-center mb-8">
			<h1 class="text-3xl font-bold text-white tracking-tight">Ondina</h1>
			<p class="text-white/60 mt-2">Acesse sua conta para continuar</p>
		</div>

		{#if errorMsg}
			<div class="bg-red-500/20 border border-red-500/50 text-red-200 px-4 py-3 rounded-lg mb-6 text-sm text-center">
				{errorMsg}
			</div>
		{/if}

		<form on:submit={handleLogin} class="space-y-5">
			<div>
				<label for="email" class="block text-sm font-medium text-white/80 mb-2">E-mail</label>
				<input 
					type="email" 
					id="email" 
					bind:value={email}
					required
					placeholder="seu@email.com"
					class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all"
				/>
			</div>

			<div>
				<label for="password" class="block text-sm font-medium text-white/80 mb-2">Senha</label>
				<input 
					type="password" 
					id="password" 
					bind:value={password}
					required
					placeholder="••••••••"
					class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all"
				/>
			</div>

			<button 
				type="submit" 
				disabled={loading}
				class="w-full mt-4 bg-purple-600 hover:bg-purple-500 disabled:opacity-50 text-white font-medium py-3 px-4 rounded-xl transition-all shadow-[0_0_15px_rgba(147,51,234,0.3)] hover:shadow-[0_0_25px_rgba(147,51,234,0.5)]"
			>
				{loading ? 'Entrando...' : 'Entrar'}
			</button>
		</form>

		<p class="mt-8 text-center text-sm text-white/60">
			Novo por aqui? <a href="/register" class="text-purple-400 hover:text-purple-300 font-medium transition-colors">Crie sua conta</a>
		</p>
	</main>
</div>
