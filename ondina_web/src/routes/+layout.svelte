<script lang="ts">
	import '../app.css';
	import Header from '$lib/components/Header.svelte';
	import Toast from '$lib/components/Toast.svelte';
	import { auth } from '$lib/stores/auth.svelte';
	import { addNotification } from '$lib/stores/notifications.svelte';
	import { Socket } from 'phoenix';
	import { onMount } from 'svelte';

	let globalSocket: Socket | null = null;
	let notifChannel: any = null;

	onMount(() => {
		auth.init();
	});

	$effect(() => {
		if (auth.isAuthenticated && !globalSocket) {
			globalSocket = new Socket('ws://localhost:4000/socket', { params: { token: auth.token } });
			globalSocket.connect();

			if (auth.user) {
				notifChannel = globalSocket.channel(`user_notifications:${auth.user.id}`, {});
				notifChannel.join()
					.receive('ok', () => console.log('Escutando notificações globais.'))
					.receive('error', () => console.error('Erro na subscrição.'));

				notifChannel.on('new_video_notification', (payload: any) => {
					addNotification(payload);
				});
			}
		} else if (!auth.isAuthenticated && globalSocket) {
			globalSocket.disconnect();
			globalSocket = null;
			notifChannel = null;
		}
	});
</script>

<Header />

<div class="pt-20 min-h-screen">
	<slot />
</div>
