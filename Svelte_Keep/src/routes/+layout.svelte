<script>
	import NavBar from '../components/NavBar.svelte';
  	import { filter } from '../store';
	import AppBar from './../components/AppBar.svelte';

	let menuOpen = true
	let title = "Keep"
</script>


<AppBar on:search={(event) => $filter = event.detail.text} bind:title on:menu={() => menuOpen = !menuOpen}/>
<main>
	<NavBar on:menuItemClick={(event) => title = event.detail.text } bind:open={menuOpen}/>
	<slot><!-- optional fallback --></slot>
</main>

<style>
	main {
		position: fixed;
		top: 105px;
		left: 0;
		right: 0;
		bottom: 0;
		background-color: white;
		display: grid;
		grid-template-columns: auto 1fr;
		grid-template-rows: 100%;
		margin: 0;
	}


	
</style>