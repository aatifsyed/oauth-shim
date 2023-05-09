<script lang="ts">
	import { page } from '$app/stores';

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
	$: result = oauth_state(search_params);
	const copy_params_to_clipboard = () => {
		navigator.clipboard.writeText(JSON.stringify(Object.fromEntries(search_params.entries())));
	};
</script>

{#if result.type == 'ok'}
	<h1>Success</h1>
	<p>Copy using the button below, and paste into the app that you're authorizing.</p>
	<p>You can then close this page.</p>
	<button on:click={copy_params_to_clipboard}>Copy authorization to clipboard</button>
{:else if result.type == 'err'}
	<h1>Authorization error</h1>
	<p>error: {result.error}</p>
	{#each [['description', result.description], ['uri', result.uri], ['state', result.state]] as [name, maybe_item]}
		{#if maybe_item != undefined}
			<p>{name}: {maybe_item}</p>
		{/if}
	{/each}
{:else}
	<h1>OAuth Shim</h1>
	<p>A simple redirect URL for OAuth applications.</p>
	<p>
		When used as a redirect, this page will present a button which copies the OAuth <code>code</code
		>
		and <code> state </code> (if present) to the user's clipboard.
	</p>
	<p>These will be copied as JSON, which the user can then paste into your application.</p>
	<p>On error, the params in the OAuth spec are printed out, if present.</p>
{/if}
