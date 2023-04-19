<script>
    import { createEventDispatcher } from 'svelte';
	import Button from './Button.svelte';

    export let open = false // state of menu
    const dispatch = createEventDispatcher();

    let tags = [ // list of buttons on nav
        {
            label: "Note",
            link: "/",
            icon: "mdi-lightbulb-outline",
            active: true,
            click: () => select("Note")
        },
        {
            label: "Archivio",
            link: "/archive",
            icon: "mdi-archive-arrow-down-outline",
            active: false,
            click: () => select("Archivio")
        },
        {
            label: "Cestino",
            link: "/trashNotes",
            icon: "mdi-trash-can-outline",
            active: false,
            click: () => select("Cestino")
        }
    ]

    /**
   * @param {string} label
   * 
   * active button clicked
   */
    function select(label) { 
        tags.forEach(element => {
            if(element.label == label) {
                element.active = true
            } else {
                element.active = false
            }
        }
        
        );
        dispatch('menuItemClick', {
			text: label
		});
        tags = tags
    }
</script>


<nav>
    {#each tags as tag }
    <a href={tag.link} style="text-decoration: none ;"><Button {...tag} on:click={tag.click} bind:closed={open}/></a>  
    {/each}
</nav>

<style>
    nav {
        display: flex;
        flex-direction: column;
        overflow-y: auto;
        height: auto;
        margin: 0;
        padding: 0;
        padding-top: 20px;
    }
</style>