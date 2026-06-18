export const notificationsState = $state({
	items: [] as any[]
});

export function addNotification(notification: any) {
	const id = Date.now() + Math.random();
	notificationsState.items.push({ ...notification, id });

	setTimeout(() => {
		const index = notificationsState.items.findIndex(n => n.id === id);
		if (index !== -1) {
			notificationsState.items.splice(index, 1);
		}
	}, 5000);
}
