<script>
    import { deletenoteStore, filter, modeList, noteStore } from "../../store";
    import Note from "../../components/Note.svelte";
    import { flip } from 'svelte/animate'
    import Icon from "@iconify/svelte";
    
    let innerHeight = 0
    let innerWidth = 0
    $: mode = (innerWidth >= 980) && $modeList
    
    



    /**
   * @param {CustomEvent<any>} event
   */
    
    function deleteNote(event) {
        let note = event.detail.note
        let array = []
        for (let index = 0; index < $noteStore.length; index++) {
            if (!($noteStore[index].title == note.title && $noteStore[index].comment == note.comment&& $noteStore[index].color == note.color)) {
                        array.push($noteStore[index])
            } 
        }
        $noteStore = array
        $deletenoteStore.push(note)
        $deletenoteStore = $deletenoteStore
    }

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
		const cardAIndex = $noteStore.indexOf(draggingCard)
		const cardBIndex = $noteStore.indexOf(card)
		$noteStore[cardAIndex] = card
		$noteStore[cardBIndex] = draggingCard
	}

   // @ts-ignore
    $: visible = (l) => ($filter == "" || ((l.title).toLocaleLowerCase()).includes($filter.toLocaleLowerCase()) || ((l.comment).toLocaleLowerCase()).includes($filter.toLocaleLowerCase()))
</script>
<svelte:window bind:innerWidth bind:innerHeight />
<article id="container">
    {#if $noteStore.filter((e) => e.archive).length > 0 }
    <h1>Note Archiviate</h1>
    <article class="DraggableGrid" style="{"grid-template-columns: repeat(" + ( !mode ? "1" : Math.round( Number(innerWidth / 350) - 1 ))  + ", 1fr);"}">
        {#each $noteStore as l (l) }
        {#if l.archive && visible(l)}
        <div class="DraggableItem" 
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
                ></Note>
        </div>
        {/if}
        {/each}
    </article>
    {:else}
    <div class="nothing">
        Nessuna nota Archiviata
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
        justify-content: center;
    }

</style>