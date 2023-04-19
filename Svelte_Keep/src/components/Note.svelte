<script>
// @ts-nocheck



    import { createEventDispatcher } from "svelte";
    import Button from "./Button.svelte";
    import NoteWriter from "./NoteWriter.svelte";

    export let title = "Titolo"
    export let comment = ""            
    export let img = ""
    export let pinned = false
    export let archive = false
    export let color = "white"
    export let wide = false
    export let trash = false
    export let draggable = false
    
    /**
   * @type {NoteWriter}
   */
    let modifyTag
    let card

    let writing = false
    
    let colorList = ["white","#26408B", "#FFA737", "#F63E02", "#F3D34A", "#4CB944"]
    let selectColor = false
    let hover= false
    function hoverin() {
        hover = true
    }

    function hoverout() {
        hover = false
        selectColor = false
    }

    const dispatch = createEventDispatcher();

	function updateEvent() {
        dispatch('update', {
			text: "update"
		});
	}
    function deleteEvent() {
        dispatch('delete', {
			note: {
                title: title,
                comment: comment,
                img: img,
                pinned: pinned,
                archive: archive,
                color: color
            } 
		});
	}
    function undoEvent() {
        dispatch('undo', {
			note: {
                title: title,
                comment: comment,
                img: img,
                pinned: pinned,
                archive: archive,
                color: color
            } 
		});
    }
    /**
   * @param {CustomEvent<any>} event
   */
    function modifyNote(event) {
        let note = event.detail.note
        title = note.title
        comment = note.comment
        img = note.img
        pinned = note.pinned
        archive = note.archive
        color = note.color
    }


</script>
{#if writing}
<div id="Modify">
    <NoteWriter bind:this={modifyTag}
        bind:writing
        title={title}
        comment={comment}
        img = {img}
        pinned = {pinned}
        archive = {archive}
        color = {color}
        on:write={(event) => modifyNote(event)}
        />
</div>

{/if}
<div id="card" bind:this={card} class={!wide ? "widecard" : "fixedcard"} style="background-color: {color};" on:dblclick={() =>{writing = !writing;}} on:mouseenter={hoverin} on:mouseleave={hoverout} draggable="{draggable}" on:dragstart on:drop|preventDefault on:dragover on:dragenter>
    {#if img != ""}
    <div id="img" class="inside">     
        <img src="{img}" alt="note"> 
    </div>
    {/if}
    <div class="inside" id="title">
        <h2 style="color: {color == "white" ? "black" : "white"};">{title}</h2>
    </div>
    {#if hover}

    {#if !trash} <!-- PIN ICON and TRASH ICONS -->
    <div id="pin">
        <Button on:click={() => {pinned = !pinned; updateEvent()}} icon="{ pinned ? 'mdi-pin' : 'mdi-pin-outline'}"/>
    </div>
    {:else}
    <div id="pin">
        <Button on:click={() => {deleteEvent()}} icon="mdi-trash"/>
        <Button on:click={() => {undoEvent()}} icon="mdi-trash-outline"/>
    </div>
    {/if} <!-- END ICONS-->

    {/if}
    <div id="comment" class="inside">
        <p style="color: {color == "white" ? "black" : "white"};">{comment}</p>
    </div>
    {#if hover && !trash}
    <div id="options" class="buttonGroup" style="{ selectColor ? "border-radius: 1em 1em 0 0;" : ""}">
        <Button on:click={() => null} size={20} icon={"mdi-bell-plus-outline"} disable={true}/>
        <Button on:click={() => null} size={20} icon={"mdi-account-multiple-check"} disable={true}/>
        <Button on:click={() => {selectColor = !selectColor; updateEvent()}} size={20} icon={"mdi-palette-outline"}/>
        <Button on:click={() => null} size={20} icon={"mdi-image-outline"}/>
        <Button on:click={() => {archive = !archive; updateEvent()}} size={20} icon={archive ?  "mdi-archive-arrow-down":"mdi-archive-arrow-down-outline"}/>
        <Button on:click={() => deleteEvent()} size={20} icon={"mdi-trash"}/>
    </div>
    {#if selectColor}
    <div class="buttonGroup" id="colors">
        {#each colorList as c }
        <button on:click={() => {color = c; selectColor = false}} style="background-color: {c};"></button>
        {/each}
    </div>
    {/if}
    {/if}
</div>

<style>
#Modify {
    position: fixed;
    display: inline-flex;
    flex-direction: row;
    align-items: flex-start;
    justify-content: center;
    top: 0;
    left: 0;
    background-color: rgba(0, 0, 0, 0.5);
    width: 100%;
    height: 100%;
    overflow-y: auto;
}

#colors {
    width: 100%;
    height: 32px;
    grid-row: 6;
    padding-top: 5px;
    padding-bottom: 5px;
    grid-column: 1 / 3;
    justify-content: space-around;
    background-color: white;
    border-radius: 0 0 1em 1em;
}

#colors button {
    width: 32px;
    border: solid black 1px;  
    border-radius: 30px;
}

#img {
    grid-row: 1;
    grid-column: 1 / 3;
    width: 100%;
    background-color: transparent;
    display: inline-flex;
    justify-content: center;
    border-radius: inherit ;
    margin: 0;
}

#img img {
    width: 100%;
    border-radius: 1em;
    margin: 0;
}

#pin {
    grid-row: 2;
    display: flex;
}
#title {
    grid-row: 2;
    height: fit-content;
}
.buttonGroup {
    display: inline-flex;
}
#comment {
    grid-row: 3;
    grid-column: 1 / 3;
}

#options {
    grid-row: 5;
    grid-column: 1 / 3;
    background-color: white;
    border-radius: 1em;
}
.inside {
    margin-top: -10px;
    margin-left: 10px;
}

#card {
    border-radius: 1em;
    min-height: 120px;  
    border: solid 0.1px black;
    display: grid;
    grid-template-columns: 1fr min-content;
    grid-template-rows: auto auto auto auto;
    
}

#card:hover {
    background-color: transparent; 
    box-shadow: 0 2.8px 2.2px rgba(0, 0, 0, 0.034),0 6.7px 5.3px rgba(0, 0, 0, 0.048),0 5px 5px rgba(0, 0, 0, 0.06),0 5px 5px rgba(0, 0, 0, 0.072),0 5px 5px rgba(0, 0, 0, 0.086), 0 5px 5px rgba(0, 0, 0, 0.12);
}

.widecard {
    width: 100%;
}

.fixedcard {
    width: 350px;
}
</style>