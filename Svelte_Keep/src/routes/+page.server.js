/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
    const res = await fetch("https://jsonplaceholder.typicode.com/photos")
    const item = await res.json()
    return {
        post: {
            list: [
                {
                    title: "Progetto",
                    comment: "Giorno 17, all'auditorium",
                    img: "favicon.png",
                    pinned: false,
                    archive: false,
                    color: "white"
                },
                {
                    title: "Matrimonio",
                    comment: "Comprare il vestito \n partenza alle 15, massimo e mezza",
                    img: "",
                    pinned: false,
                    archive: false,
                    color: "white"
                },
                {
                    title: "studio",
                    comment: "algo: ok, prog da fare, thread e junit",
                    img: "",
                    pinned: true,
                    archive: false,
                    color: "white"
                },
                {
                    title: "Progetto 2",
                    comment: "Giorno 30, presentazione",
                    img: "",
                    pinned: false,
                    archive: false,
                    color: "white"
                },
                {
                    title: "compleanno",
                    comment: "festa a sorpresa? torta? quanti saremmo?",
                    img: "",
                    pinned: false,
                    archive: false,
                    color: "white"
                },
                {
                    title: "boh",
                    comment: "non so cosa scrivere",
                    img: "",
                    pinned: false,
                    archive: false,
                    color: "white"
                }],
            
            fromAPI: item
    
            }
    };
}