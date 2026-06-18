<script lang="ts">
	import { notificationsState } from '$lib/stores/notifications.svelte';
	import { fly } from 'svelte/transition';
</script>

<div class="fixed top-24 right-6 z-[200] flex flex-col space-y-4 pointer-events-none">
	{#each notificationsState.items as notif (notif.id)}
		<div 
			transition:fly={{ x: 50, duration: 400 }}
			class="pointer-events-auto flex items-center space-x-4 bg-black/60 backdrop-blur-xl border border-white/20 p-3 rounded-2xl shadow-[0_10px_40px_rgba(147,51,234,0.3)] w-80 overflow-hidden relative group"
		>
			<div class="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-pink-500/10 z-0"></div>
			
			<div class="w-14 h-14 rounded-lg bg-black/50 overflow-hidden shrink-0 z-10 border border-white/10 relative">
				<img src={notif.thumbnail_url} alt="thumbnail" class="w-full h-full object-cover" />
			</div>
			
			<div class="flex-1 min-w-0 z-10">
				<p class="text-[10px] font-bold text-purple-400 uppercase tracking-wider mb-0.5">Novo Vídeo • {notif.creator_name}</p>
				<p class="text-sm font-semibold text-white truncate">{notif.title}</p>
			</div>

			<a href={`/video/${notif.video_id}`} class="absolute inset-0 z-20"></a>
		</div>
	{/each}
</div>
