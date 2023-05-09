<script lang="ts">
	import { page } from '$app/stores';
	import Button from '../components/Button.svelte';

	type OAuthSuccess = {
		type: 'ok';
		code: string;
		state?: string;
	};
	type OAuthError = {
		type: 'err';
		error: string;
		description?: string;
		uri?: string;
		state?: string;
	};
	type Unrecognized = {
		type: 'idk';
	};

	function oauth_state(params: URLSearchParams): OAuthSuccess | OAuthError | Unrecognized {
		let code = params.get('code');
		if (code != null) {
			return {
				type: 'ok',
				code: code,
				state: params.get('state') ?? undefined
			};
		}
		let error = params.get('error');
		if (error != null) {
			return {
				type: 'err',
				error: error,
				description: params.get('error_description') ?? undefined,
				uri: params.get('error_uri') ?? undefined,
				state: params.get('state') ?? undefined
			};
		}
		return { type: 'idk' };
	}

	$: search_params = $page.url.searchParams;
	$: state = oauth_state(search_params);
	const copy_params_to_clipboard = () => {
		navigator.clipboard.writeText(JSON.stringify(Object.fromEntries(search_params.entries())));
	};
</script>

{#if state.type == 'ok'}
	<Button on_click={(_) => copy_params_to_clipboard()}>copy</Button>
{:else if state.type == 'err'}
	TODO: display error
{:else}
	TODO: landing page
{/if}
