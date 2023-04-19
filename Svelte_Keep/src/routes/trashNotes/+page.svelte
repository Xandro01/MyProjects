<script>
    import { deletenoteStore, modeList, noteStore } from "../../store";
    import Note from "../../components/Note.svelte";
    import { onMount } from "svelte";
    import { flip } from 'svelte/animate'
    import Button from "../../components/Button.svelte";
    import Icon from "@iconify/svelte";
    
    let innerHeight = 0
    let innerWidth = 0
    $: mode = (innerWidth >= 980) && $modeList
    
    



    /**
   * @param {CustomEvent<any>} event
   */
    
    function deleteNote(event) {
        count++
        let note = event.detail.note
        let array = []
        for (let index = 0; index < $deletenoteStore.length; index++) {
            if ($deletenoteStore[index].title == note.title && $deletenoteStore[index].comment == note.comment
                    && $deletenoteStore[index].color == note.color) {
                
            } else {
                array.push($deletenoteStore[index])
            }
        }
        $deletenoteStore = array
        
    }
    /**
   * @param {CustomEvent<any>} event
   */
    function undoNote(event) {
        deleteNote(event)
        $noteStore.push(event.detail.note)
        $noteStore = $noteStore
    }
    let count = 0

    //DRAGGING
    const dragDuration = 300
	/**
   * @type {{ title: string; comment: string; img: string; pinned: boolean; archive: boolean; color: string; }}
   */
	let draggingCard
	let animatingCards = new Set()

	/**
   * @param {{ title: string; comment: string; img: string; pinned: boolean; archive: boolean; color: string; }} card
   */
	function swapWith(card) {
		if (draggingCard === card || animatingCards.has(card)) return
		animatingCards.add(card)
		setTimeout(() => animatingCards.delete(card), dragDuration)
		const cardAIndex = $deletenoteStore.indexOf(draggingCard)
		const cardBIndex = $deletenoteStore.indexOf(card)
		$deletenoteStore[cardAIndex] = card
		$deletenoteStore[cardBIndex] = draggingCard
	}

    let a = 0
</script>
<svelte:window bind:innerWidth bind:innerHeight />
<article id="container">
    {#if $deletenoteStore.length > 0}
    <button on:click={() => $deletenoteStore = []}>
        <p>Svuota Cestino</p>
    </button>
    <h1 class="label">Note Eliminate</h1>
    
    <article class="DraggableGrid" style="{"grid-template-columns: repeat(" + ( !mode ? "1" : Math.round( Number(innerWidth / 350) - 1 ))  + ", 1fr);"}">
        {#each $deletenoteStore as l (l) }
        <div class="DraggableItem" 
                animate:flip={{ duration: dragDuration }}
                draggable="true"
                on:dragstart={() => draggingCard = l}
                on:dragend={() => draggingCard = { title: "", comment: "", img: "", pinned: false, archive: false, color: "" }}
                on:dragenter={() => swapWith(l)}
                on:dragover|preventDefault>
                
                <Note bind:wide={mode} 
                bind:title={l.title}
                bind:comment={l.comment}
                bind:img={l.img}
                bind:pinned={l.pinned}
                bind:archive={l.archive}
                bind:color={l.color}
                on:delete={(event) => {deleteNote(event)}}
                on:undo={(event) => undoNote(event)}
                trash ={true}
                ></Note>
        </div>
        {/each}
    </article>
    {:else}
    <div class="nothing">
        <Icon icon={"mdi-trash-outline"} width={200} style="color: lightgray;"></Icon> 
        Nessuna nota nel Cestino
    </div>
    {/if}
</article>


<style>

    .nothing{
        font-size: xx-large; 
        color: grey; 
        display: flex; 
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100%;
    }
    .label {
        margin-left: 100px;
        margin-right: auto;
        font-size: x-large;
    }

    .DraggableGrid {
        display: grid;
		gap: 5px;
        width: auto;
        margin-left: 6%;
        margin-right: 10%;
        margin-bottom: 20px;
    }

    .DraggableItem {
        width: fit-content;
        display: flex;
        align-items: baseline;
        justify-self: center;
    }

    #container {
        overflow-y: auto;
        overflow-x: hidden;
        display: flex;
        flex-direction: column;
        justify-content: start;
        align-items: center;
    }

    button {
        text-align: center;
        background-color: rgba(72, 180, 247, 0.05);
        padding: 15px;
        padding-left: 25px;
        padding-right: 25px;
        font-size: large;
        color: rgb(72, 180, 247);
        margin: 5px;
        border-style: none;
        border-radius: 15px;
    }

    button:hover {
        background-color: rgba(72, 180, 247, 0.1);
    }

</style>