import type { PageLoad } from './$types';
import { error } from '@sveltejs/kit';

export const load: PageLoad = async ({ params, fetch }) => {
	const res = await fetch(`http://localhost:4000/api/videos/${params.id}`);

	if (!res.ok) {
		if (res.status === 404) {
			error(404, 'Vídeo não encontrado');
		}
		error(500, 'Erro ao buscar o vídeo');
	}

	const json = await res.json();
	return {
		video: json.data
	};
};
