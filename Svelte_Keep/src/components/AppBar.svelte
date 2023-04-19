<script>
	import { deletenoteStore, modeList, noteStore } from './../store.js';
    import Icon from '@iconify/svelte';
    import Button from './Button.svelte';
    import { createEventDispatcher } from 'svelte';


    // SearchBar
    let innerWidth = 0;
    let innerHeight = 0;
    $: condition = innerWidth >= 980

        // focus
    let style_shadow = "background-color: white; "
    let focus = false
    let searchValue = ""
    export let title = "Keep"

    /**
   * @type {boolean}
   */
    let modeListValue;
	modeList.subscribe(value => {
		modeListValue = value;
	});
    // Buttons
    $: icon = "mdi-" + (modeListValue ?   "view-agenda-outline" : "view-grid-outline")

    const dispatch = createEventDispatcher();

	function searchBarEvent() {
        dispatch('search', {
			text: searchValue
		});
	}

    function openMenu() {
        dispatch('menu', {
			text: 'Request open/close menu'
		});
    }

    
</script>

<svelte:window bind:innerWidth bind:innerHeight />
<header class="shadow">
    <div class="item buttonGroup">
        <Button on:click={openMenu}/>
        <span id="logo" class="item">
            {#if title == "Note"}
            <img src="/logo.png" style="width: 50px;" alt="logo">
            {/if}
            <!-- svelte-ignore a11y-invalid-attribute -->
            <a href="#" style="float: right; text-decoration: none;">
                {#if title == "Note"}
                    Keep
                {:else}
                    <p>{title}</p>
                {/if}

            </a>
        </span>
    </div>
    {#if condition}
    <div id="searchbar" class:shadow="{ focus }" style={ focus ? style_shadow : ""}>
        <Button  on:click={searchBarEvent} icon="mdi-search" size={condition ? 24 : 32}/>
        <input class="item" on:change={searchBarEvent} bind:value={searchValue} type="search" placeholder="Cerca" on:focus={()=>focus=true} on:blur={()=>focus=false}>
    </div>
    {/if}
    <div class="item buttonGroup">
        {#if !condition}
        <Button icon="mdi-search"/>
        {/if}
        {#if $noteStore.length > 0 || $deletenoteStore.length > 0}
        <Button icon="mdi-refresh" on:click={() => { $deletenoteStore = []; $noteStore = [] }}/>
        {/if}
        {#if condition}
        <Button bind:icon={icon} on:click={ () => {modeList.update(n => !n);} }/>
        {/if}
        <Button icon="mdi-cog-outline" disable={true}/>
        <Button icon="mdi-dots-grid" disable={true}/>
        <button id="avatar">a</button> 
    </div>
    
</header>

<style>
    #logo {
        min-width: 120px;
    }

    #searchbar {
        display: flex;
        align-items: center;
        background-color: rgba(0, 0, 0, 0.1);
        border-radius: 10px;
        padding: 5px;
        height: 50px;
        flex-grow: 2;
        margin-left: 100px;
        margin-right: 20px;
        margin-top: 5px;
        margin-bottom: 5px;
    }

    #searchbar input {
        flex-grow: 2;
        background-color: transparent;
        border: none;
        line-height: 3em;
        font-size: large;
    }

    #searchbar input:focus {
        outline: none !important;
        
    }


    #avatar {
        border-radius: 100px;
        border-style: none;
        background-color: seagreen;
        height: 40px;
        width: 40px;
        font-size: larger;
        color: white;
    }

    a {
        font-size: 30px;
        margin: 0;
        margin-top: 10px;
        text-align: center;
        height: 100%;
    }

    a:visited {
        color: grey;
        border: none;
    }

    header {
        background-color: white;
        border-bottom: solid 0.01em grey;
        padding: 5px;
        padding-left: 10px;
        padding-right: 25px;
        display:flex;
        align-items: center;
        justify-content: space-between;
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        height: 90px;
    }

    .buttonGroup {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 0.2em;
    }

    .item {
        background-color: transparent;
    }

    .shadow {
        background-color: transparent; 
        box-shadow: 0 2.8px 2.2px rgba(0, 0, 0, 0.034),0 6.7px 5.3px rgba(0, 0, 0, 0.048),0 5px 5px rgba(0, 0, 0, 0.06),0 5px 5px rgba(0, 0, 0, 0.072),0 5px 5px rgba(0, 0, 0, 0.086), 0 5px 5px rgba(0, 0, 0, 0.12);
    }

</style>