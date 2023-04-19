import { browser } from "$app/environment";
import { writable } from "svelte/store";

export const modeList = writable(false)

export const filter = writable("")




// create an object w/default values
let note = [{
    title: "noteTitle",
    comment: "noteComment",
    img: "",
    pinned: false,
    archive: false,
    color: "white"
}]

let deletenote = [{
    title: "noteTitle",
    comment: "noteComment",
    img: "",
    pinned: false,
    archive: false,
    color: "white"
}]

  // ensure this only runs in the browser
if (browser) {
    // if the object already exists in localStorage, get it
    // otherwise, use our default values
    // @ts-ignore
    note = JSON.parse(localStorage.getItem('note')) || note;
    // @ts-ignore
    deletenote = JSON.parse(localStorage.getItem('deletenote')) || deletenote;
}
  // export the store for usage elsewhere
export const noteStore = writable(note);
export const deletenoteStore = writable(deletenote);

if (browser) {
    // update localStorage values whenever the store values change
    noteStore.subscribe((value) =>
      // localStorage only allows strings
      // IndexedDB does allow for objects though... 🤔
    localStorage.setItem('note', JSON.stringify(value))
    );

    deletenoteStore.subscribe((value) =>
      // localStorage only allows strings
      // IndexedDB does allow for objects though... 🤔
    localStorage.setItem('deletenote', JSON.stringify(value))
    );
}