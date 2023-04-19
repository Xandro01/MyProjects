<script>
// @ts-nocheck

	import { deletenoteStore, filter, modeList, noteStore} from './../store.js';
    import Note from './../components/Note.svelte';
    import { onMount } from 'svelte';
    import Icon from '@iconify/svelte';
    import NoteWriter from '../components/NoteWriter.svelte';


    /** @type {import('./$types').PageData} */
    export let data;

    
    /**
   * @type {any[]}
   */
    let randomNotes = []
    const maxRandomNotes = 10
    // take random notes from API
    onMount( () => {
        for (let index = 0; index < Math.round(Math.random() * maxRandomNotes); index++) {
            let i = data.post.fromAPI[Math.round(Math.random() * 5000)] // take random notes
            randomNotes.push({ // notes
                title: i.title, 
                comment: "Random image num: " + i.id,
                img: i.url,
                pinned: false,
                archive: false,
                color: "white"
            })
        } // end for loop
        randomNotes = randomNotes
        $noteStore = $noteStore.concat(randomNotes)
    } )

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
    /** SUBSCRIVE STORES VALUE: modeList
   * @type {boolean}
   */
    let modeListValue;

	modeList.subscribe(value => {
		modeListValue = value;
	});

    
    // window sizes
    $: mode = (innerWidth >= 980) && modeListValue // size condition
    let innerHeight = 0
    let innerWidth = 0

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
	function swapWith(card) { // on:dragenter handler
		if (draggingCard === card || animatingCards.has(card)) return
		animatingCards.add(card)
		setTimeout(() => animatingCards.delete(card), dragDuration)
		const cardAIndex = $noteStore.indexOf(draggingCard)
		const cardBIndex = $noteStore.indexOf(card)
		$noteStore[cardAIndex] = card
		$noteStore[cardBIndex] = draggingCard
	}

   // @ts-ignore
    $: visible = (l) => !l.archive && ($filter == "" || ((l.title).toLocaleLowerCase()).includes($filter.toLocaleLowerCase()) || ((l.comment).toLocaleLowerCase()).includes($filter.toLocaleLowerCase()))

    $: column = Math.round( Number(innerWidth / 425) - 1 )
</script>

<svelte:window bind:innerWidth bind:innerHeight />
<article id="container">
    {column}
    <NoteWriter on:write={(e) => {$noteStore.push(e.detail.note); $noteStore = $noteStore}}></NoteWriter>
    {#if $noteStore.filter((e) => visible(e)).length > 0 }
    {#if $noteStore.filter((e) => visible(e) && e.pinned).length > 0}
    <h4 class="label">Appuntate</h4>
    {/if}
    <article class="DraggableGrid" style="{"grid-template-columns: repeat(" + ( !mode ? "1" : column)  + ", 1fr);"}">
        {#each $noteStore as l (l)}
        {#if l.pinned}
        {#if visible(l) }
        <div class="DraggableItem"
            draggable="true"
            on:dragstart={() => draggingCard = l}
            on:dragend={() => draggingCard = { title: "", comment: "", img: "", pinned: false, archive: false, color: "" }}
            on:dragenter={() => swapWith(l)}
            on:dragover|preventDefault>
            <!--Note --------------------------------->
            <Note bind:wide={mode} 
                bind:title={l.title}
                bind:comment={l.comment}
                bind:img={l.img}
                bind:pinned={l.pinned}
                bind:archive={l.archive}
                bind:color={l.color}
                on:delete={(event) => deleteNote(event)}
                ></Note>
            <!------------------------------------------>
        </div>
        {/if}
        {/if}
        {/each} 
    </article>
    {#if $noteStore.filter((e) => visible(e) && e.pinned).length > 0 && $noteStore.filter((e) => visible(e) && !e.pinned).length > 0}
    <h4 class="label">Altre</h4>
    {/if}
    <article class="DraggableGrid" style="{"grid-template-columns: repeat(" + ( !mode ? "1" : column)  + ", 1fr);"}">
        {#each $noteStore as l }
        {#if !(l.pinned)}
        {#if visible(l) }

        <div class="DraggableItem"
            draggable="true"
            on:dragstart={() => draggingCard = l}
            on:dragend={() => draggingCard = { title: "", comment: "", img: "", pinned: false, archive: false, color: "" }}
            on:dragenter={() => swapWith(l)}
            on:dragover|preventDefault>
            <!--Note -->
            <Note bind:wide={mode} 
                bind:title={l.title}
                bind:comment={l.comment}
                bind:img={l.img}
                bind:pinned={l.pinned}
                bind:archive={l.archive}
                bind:color={l.color}
                on:delete={(event) => deleteNote(event)}
                ></Note>
        </div>
        {/if}
        {/if}
        {/each}        
    </article>
    {:else}
    <div class="nothing">
        <Icon icon={"mdi-lightbulb-outline"} width={200} style="color: lightgray;"></Icon>
        Le note verranno visualizzate qui
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

    
    #container {
        margin-bottom: 2em;
        display: flex;
        flex-direction: column;
        align-items: center;
        height: 100%;
        width: 100%;
        overflow-y: auto;
        overflow-x: 0;
        padding-top: 20px;
    }
    .label {
        margin-left: 100px;
        color: grey;
        margin-right: auto;
        font-size: x-large;
    }

    .DraggableGrid {
        display: grid;
		gap: 5px;
        width: auto;
        margin-left: 10%;
        margin-right: 10%;
        margin-bottom: 20px;
    }

    .DraggableItem {
        width: fit-content;
        display: flex;
        align-items: baseline;
    }



</style>