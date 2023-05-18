<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';

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

	function to_json(result: OAuthSuccess | OAuthError | Unrecognized): string {
		return JSON.stringify(result, (k, v) => {
			// skip discriminator
			return k == 'type' ? undefined : v;
		});
	}

	onMount(() => {
		result = oauth_state($page.url.searchParams);
	});

	let result: OAuthSuccess | OAuthError | Unrecognized = { type: 'idk' };

	const oauth_to_clipboard = () => {
		navigator.clipboard.writeText(to_json(result));
	};
</script>

{#if result.type == 'ok'}
	<main>
		<h1>Success</h1>
		<p>Copy using the button below, and paste into the app that you're authorizing.</p>
		<p>You can then close this page.</p>
		<button on:click={oauth_to_clipboard}>Copy authorization to clipboard</button>
	</main>
{:else if result.type == 'err'}
	<main style="--color-accent: #cc00aa44">
		<h1>Authorization error :(</h1>
		<p>Please report a bug to the app developer that sent you here.</p>
		<p>Here is additional information about the error:</p>
		<br />
		<table>
			<tr>
				<th>parameter</th>
				<th>value</th>
			</tr>
			<tr>
				<td><code>error</code></td>
				<td><code>{result.error}</code></td>
			</tr>
			{#each [['description', result.description], ['uri', result.uri], ['state', result.state]] as [name, maybe_item]}
				{#if maybe_item != undefined}
					<tr>
						<td><code>{name}</code></td>
						<td><code>{maybe_item}</code></td>
					</tr>
				{/if}
			{/each}
		</table>
	</main>
{:else}
	<main>
		<h1>OAuth Shim</h1>
		<p>A simple redirect URL for OAuth applications.</p>
		<p>
			When used as a redirect, this page will present a button which copies the OAuth <code
				>code</code
			>
			and <code> state </code> (if present) to the user's clipboard.
		</p>
		<p>These will be copied as JSON, which the user can then paste into your application.</p>
		<p>On error, the params in the OAuth spec are printed out, if present.</p>
	</main>
{/if}
