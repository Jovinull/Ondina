<script lang="ts">
	import { auth } from '$lib/stores/auth.svelte';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	let title = $state('');
	let description = $state('');
	let videoFile = $state<File | null>(null);
	let thumbnailFile = $state<File | null>(null);
	let loading = $state(false);
	let errorMsg = $state('');

	onMount(() => {
		if (auth.isInitialized && !auth.isAuthenticated) {
			goto('/login');
		}
	});

	$effect(() => {
		if (auth.isInitialized && !auth.isAuthenticated) {
			goto('/login');
		}
	});

	function handleVideoSelect(e: Event) {
		const target = e.target as HTMLInputElement;
		if (target.files && target.files.length > 0) {
			videoFile = target.files[0];
		}
	}

	function handleThumbSelect(e: Event) {
		const target = e.target as HTMLInputElement;
		if (target.files && target.files.length > 0) {
			thumbnailFile = target.files[0];
		}
	}

	async function handleSubmit(e: Event) {
		e.preventDefault();
		if (!videoFile || !thumbnailFile) {
			errorMsg = 'Por favor, selecione os arquivos de vídeo e capa.';
			return;
		}

		loading = true;
		errorMsg = '';

		const formData = new FormData();
		formData.append('title', title);
		formData.append('description', description);
		formData.append('video', videoFile);
		formData.append('thumbnail', thumbnailFile);

		try {
			const res = await fetch('http://localhost:4000/api/videos', {
				method: 'POST',
				headers: {
					'Authorization': `Bearer ${auth.token}`
				},
				body: formData
			});

			if (res.ok) {
				const data = await res.json();
				goto(`/video/${data.id}`);
			} else {
				const data = await res.json();
				errorMsg = data.error || 'Erro ao realizar upload.';
			}
		} catch (err) {
			errorMsg = 'Erro de rede ao enviar os arquivos.';
		} finally {
			loading = false;
		}
	}
</script>

<div class="min-h-screen flex items-center justify-center bg-black relative font-sans p-6">
	<!-- Background Aesthetics -->
	<div class="absolute inset-0 z-0 overflow-hidden">
		<div class="absolute top-0 right-0 w-[60%] h-[60%] bg-blue-900/20 rounded-full blur-[150px]"></div>
		<div class="absolute bottom-0 left-0 w-[60%] h-[60%] bg-purple-900/20 rounded-full blur-[150px]"></div>
	</div>

	<main class="relative z-10 w-full max-w-2xl p-8 md:p-10 bg-white/5 backdrop-blur-2xl border border-white/10 rounded-3xl shadow-2xl">
		<div class="text-center mb-8">
			<h1 class="text-3xl md:text-4xl font-bold text-white tracking-tight">Nova Postagem</h1>
			<p class="text-white/60 mt-2">Compartilhe sua visão com o mundo</p>
		</div>

		{#if errorMsg}
			<div class="bg-red-500/20 border border-red-500/50 text-red-200 px-4 py-3 rounded-lg mb-6 text-sm text-center">
				{errorMsg}
			</div>
		{/if}

		<form on:submit={handleSubmit} class="space-y-6">
			<div>
				<label for="title" class="block text-sm font-medium text-white/80 mb-2">Título do Vídeo</label>
				<input 
					type="text" 
					id="title" 
					bind:value={title}
					required
					placeholder="Ex: A Grande Onda..."
					class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all"
				/>
			</div>

			<div>
				<label for="description" class="block text-sm font-medium text-white/80 mb-2">Descrição</label>
				<textarea 
					id="description" 
					bind:value={description}
					required
					rows="3"
					placeholder="Sobre o que é este vídeo?"
					class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all resize-none"
				></textarea>
			</div>

			<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
				<!-- Upload Vídeo -->
				<div>
					<label class="block text-sm font-medium text-white/80 mb-2">Arquivo de Vídeo (.mp4)</label>
					<label for="videoFile" class="flex flex-col items-center justify-center w-full h-32 border-2 border-white/10 border-dashed rounded-xl cursor-pointer bg-white/5 hover:bg-white/10 transition-colors">
						<div class="flex flex-col items-center justify-center pt-5 pb-6">
							{#if videoFile}
								<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-purple-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
								</svg>
								<p class="text-sm text-purple-300 text-center truncate px-4 w-full">{videoFile.name}</p>
							{:else}
								<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white/40 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
								</svg>
								<p class="text-sm text-white/60">Selecionar Vídeo</p>
							{/if}
						</div>
						<input id="videoFile" type="file" accept="video/mp4,video/x-m4v,video/*" class="hidden" on:change={handleVideoSelect} />
					</label>
				</div>

				<!-- Upload Capa -->
				<div>
					<label class="block text-sm font-medium text-white/80 mb-2">Capa do Vídeo (.jpg/png)</label>
					<label for="thumbFile" class="flex flex-col items-center justify-center w-full h-32 border-2 border-white/10 border-dashed rounded-xl cursor-pointer bg-white/5 hover:bg-white/10 transition-colors">
						<div class="flex flex-col items-center justify-center pt-5 pb-6">
							{#if thumbnailFile}
								<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-purple-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
								</svg>
								<p class="text-sm text-purple-300 text-center truncate px-4 w-full">{thumbnailFile.name}</p>
							{:else}
								<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white/40 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
								</svg>
								<p class="text-sm text-white/60">Selecionar Imagem</p>
							{/if}
						</div>
						<input id="thumbFile" type="file" accept="image/jpeg,image/png,image/webp" class="hidden" on:change={handleThumbSelect} />
					</label>
				</div>
			</div>

			<button 
				type="submit" 
				disabled={loading || !videoFile || !thumbnailFile}
				class="w-full mt-6 flex items-center justify-center space-x-2 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 disabled:opacity-50 text-white font-medium py-3.5 px-4 rounded-xl transition-all shadow-[0_0_20px_rgba(147,51,234,0.3)] hover:shadow-[0_0_30px_rgba(147,51,234,0.5)]"
			>
				{#if loading}
					<svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
						<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
						<path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
					</svg>
					<span>Processando Upload...</span>
				{:else}
					<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
					</svg>
					<span>Publicar Vídeo</span>
				{/if}
			</button>
		</form>
	</main>
</div>
