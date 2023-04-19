<script>
    import Icon from '@iconify/svelte';

    export let label = ""
    export let icon = "mdi-menu"
    export let size = 32
    export let active = false
    export let closed = true
    export let disable = false
</script>

<!-- button -->
<button class="iconbutton" class:xactive="{ active }" class:open="{!closed}" class:variant="{ label != "" }" style={disable ? "color: grey" : ""} on:click>
    <Icon bind:icon={icon} bind:width={size}></Icon> 
    {#if label != ""}
    {#if !closed}
    <h2>{ label }</h2>
    {/if}
    {/if}
</button>


<style>
    .iconbutton {
        display: flex;
        color: black;
        align-items: center;
        gap: 2em;
        background-color: transparent;
        border-style: none;
        
    }

    button {
        border-radius: 5em;
        padding: 1.2em;
        margin: 5px;
    }

    .iconbutton:hover {
        background-color: rgba(0, 0, 0, 0.1)
        
    }

    .xactive {
        background-color: rgba(254,239,195,255);
    }

    .xactive:hover {
        background-color: rgba(254,239,195,255);
    }

    .variant {
        text-decoration: none;
    }

    .open {
        padding: 10px;
        padding-left: 32px;
        width: 350px;
        margin: 0;
        border-radius: 0em 3em 3em 0em;
    }


</style>