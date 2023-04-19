<script>
// @ts-nocheck




    import Dropzone from "svelte-file-dropzone/Dropzone.svelte";
    import { createEventDispatcher } from "svelte";
    import Button from "./Button.svelte";

    const dispatch = createEventDispatcher();


    export let writing = false

    export let pinned = false

    export let archive = false
    let colorList = ["white","#26408B", "#FFA737", "#F63E02", "#F3D34A", "#4CB944"]
    export let color = colorList[0]
    let selectColor = false
    /**
   * @type {string | ArrayBuffer | null}
   */
    export let img

    /**
   * @param {{ pinned: boolean; archive: boolean; title: string; comment: string; color: string; img: string | ArrayBuffer | null; list: { text: string; checked: boolean; }[]; }} element
   */
    export function set(element) {
        pinned = element.pinned
        archive = element.archive
        title = element.title
        textarea.value = element.comment
        color = element.color
        img = element.img

    }
    /**
   * @type {HTMLInputElement}
   */
    let fileInput
    
    // @ts-ignore
    const onFileSelected =(e)=>{
            let image = e.target.files[0];
            let reader = new FileReader();
            reader.readAsDataURL(image);
            reader.onload = e => {
                // @ts-ignore
                img = e.target.result
            };
            writing = true
    }

    let options = [
        {
            icon: "mdi-bell-plus-outline",
            click: function() {
                return;
            }
        },
        {
            icon: "mdi-account-multiple-check",
            click: function() {
                return;
            }
        },
        {
            icon: "mdi-palette-outline",
            click: function() {
                selectColor = !selectColor
            }
        },
        {
            icon: "mdi-image-outline",
            click: function() {
                fileInput.click()
            }
        },
        {
            icon: "mdi-archive-arrow-down-outline",
            click: function() {
                archive = !archive
            }
        },
        {
            icon: "mdi-dots-vertical",
            click: function() {
                return;
            }
        },
    ]
    // Note Data
    /**
   * @type {HTMLTextAreaElement}
   */
    export let textarea // body note
    /**
   * @type {any}
   */
    export let comment
    function resizeTextArea() {
        textarea.style.height = "32px"
        textarea.style.height = textarea.scrollHeight + "px"
    }

    export let title = "" //  title note

    function onClose() {
        writing = false
        selectColor = false
        if (title.trim() == "" && textarea.value.trim() == "") {
            img = ""
            pinned = false
            archive = false
            color = colorList[0]
            title = ""
            textarea.value = ""
            resizeTextArea()
            return
        }
        let noteTitle = title
        let noteComment = textarea.value
        title = ""
        textarea.style.height = "32px"
        textarea.value = ""
        dispatch('write', {
			note: {
                title: noteTitle,
                comment: noteComment,
                img: img ? img : "",
                pinned: pinned,
                archive: archive,
                color: color
            }
		});
        img = ""
        pinned = false
        archive = false
        color = colorList[0]
        resizeTextArea()
    }
    let count = 0
    let dropping = false
    let files = {
        accepted: [],
        rejected: []
    };

    /**
   * @param {{ detail: { acceptedFiles: any; fileRejections?: any; }; }} e
   */
    function handleFilesSelect(e) {
        count = e.detail.acceptedFiles
        dropping = false
        writing = true
        const { acceptedFiles, fileRejections } = e.detail;
        // @ts-ignore
        files.accepted = [...files.accepted, ...acceptedFiles];
        // @ts-ignore
        files.rejected = [...files.rejected, ...fileRejections];
        // @ts-ignore
        let img1 = (files.accepted.pop()).path
        img = img1

    }

</script>
<div id="newNote" style="background-color: {color}"on:dragenter={() => dropping = true} on:dragleave={() => dropping = false}>
    
    <input on:change={(e)=>onFileSelected(e)} style="display: none;" type="file" accept=".jpg, .jpeg, .png" bind:this={fileInput}>
    {#if dropping}
    <div class="dropzone">
        <Dropzone on:drop={handleFilesSelect} multiple={false}>
        <div class="zone">Drop Image Here</div>
        </Dropzone>
    </div>
    {:else}
    {#if writing}
    {#if img}
    <div id="img" class="inside">
        <img src="{img}" alt="note"> 
        <div id="deleteIMG">
            <Button icon={"mdi-close"} on:click={() => img=""} ></Button> 
        </div>  
    </div>
    {/if}
    <input id="title" type="text" placeholder="Titolo" bind:value={title}>
    <div id="pin">
        <Button on:click={() => pinned = !pinned} icon={pinned ? "mdi-pin" : "mdi-pin-outline"}/>
    </div>
    {/if}
    <textarea bind:this={textarea} bind:value={comment} on:input={resizeTextArea}  on:focus={() => writing = true} id="{ writing ? "note" : ""}" style="width: 100%;" placeholder={"Scrivi una nota..."}></textarea>
    
    
    {#if !writing}
    <div class="buttonGroup">
        <Button icon="mdi-image-outline" on:click={() => fileInput.click() }/>
    </div>
    {/if}
    {#if writing}
    <div id="options" class="buttonGroup">
        <Button on:click={options[0].click} size={20} icon={"mdi-bell-plus-outline"} disable={true} />
        <Button on:click={options[1].click} size={20} icon={"mdi-account-multiple-check"} disable={true} />
        <Button on:click={options[2].click} size={20} icon={"mdi-palette-outline"}/>
        <Button on:click={options[3].click} size={20} icon={"mdi-image-outline"}/>
        <Button on:click={options[4].click} size={20} icon={archive ?  "mdi-archive-arrow-down":"mdi-archive-arrow-down-outline"}/>
        <Button on:click={options[5].click} size={20} icon={"mdi-dots-vertical"} disable={true} />
    </div>
    <div class="close">
        <button on:click={onClose}>Chiudi</button>
    </div>
    {#if selectColor}
    <div class="buttonGroup" id="colors">
        {#each colorList as c }
        <button on:click={() => {color = c; selectColor = false}} style="background-color: {c};"></button>
        {/each}
    </div>
    {/if}
    {/if}
    {/if}
</div>

<style>
    .zone {
        height: 180px;
        width: 100%;
        margin: -10px;
        font-size: xx-large;
        border-style: dotted;
        border-radius: 10px;
        border-color: grey;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .dropzone {
        height: 200px;
    }
    #deleteIMG {
        position: relative;
        top: 10px;
        right: 10px;
    }

    #deleteIMG {
        position: relative;
        top: 0;
        right: 20px;
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
    }
    #colors {
        margin: 5px;
        margin-left: 20px;
        width: 100%;
        height: 32px;
        grid-row: 5;
        justify-content: space-around;
    }

    #colors button {
        width: 32px;
        border: solid black 1px;  
        border-radius: 30px;
    }

    .close button {
        background-color: transparent;
        border: none;
        font-size: large;
        margin-right: 20px;
        padding: 20px;
        min-height: 50px;
        border-radius: 25px;
    }

    .close {
        grid-row: 5;
    }

    .close button:hover {
        background-color: rgba(0, 0, 0, 0.134);
    }

    #note {
        grid-column: 1 / 3
    }

    #options {
        grid-row: 5;
    }
    .buttonGroup {
        display: inline-flex;
    }
    #newNote {
        width: 75%;
        max-width: 800px;
        border-radius: 1em;
        border-style: solid;
        border-width: 0.1px;
        border-color: grey;
        box-shadow: 0 2.8px 2.2px rgba(0, 0, 0, 0.034),0 6.7px 5.3px rgba(0, 0, 0, 0.048),0 5px 5px rgba(0, 0, 0, 0.06),0 5px 5px rgba(0, 0, 0, 0.072),0 5px 5px rgba(0, 0, 0, 0.086), 0 5px 5px rgba(0, 0, 0, 0.12);
        display: grid;
        grid-template-columns: 1fr min-content;
        align-items: center;
        padding: 1em;
        padding-left: 2em;
    }

    #pin {
        display: flex;
        flex-direction: row-reverse;
    }

    #newNote textarea {
        font-size: 30px;
        text-align:left;
        background-color: transparent;
        height: 32px;
        max-width: 80%;
        padding-top: 0;
        border: none;
        resize: none;
        overflow-wrap: normal;
    }
    input {
        font-size: 30px;
        text-align:left;
        background-color: transparent;
        height: auto;
        max-width: 80%;
        padding-top: 0;
        border: none; 
    }

    input:focus {
        outline: none !important;
    }
    #newNote textarea:focus {
        outline: none !important;
        
    }
</style>