(function (words_arr) {
    let data_arr = [];
    let state = {
        current_node_ptr: null,
        last_node_ptr: null,
    };
    let staging_obj = null;
    [].forEach.call(document.querySelector('#articles').children, node => {
        // state.current_node_ptr = node;
        if (node.tagName.toLowerCase() === 'dt') {
            // console.log(node.tagName);
            staging_obj = {};
            staging_obj.id = node.querySelector(`a[href][title="Abstract"]`).id;
            staging_obj.title = 'no title';
            data_arr.push(staging_obj);
        };
        if (node.tagName.toLowerCase() === 'dd') {
            staging_obj.title = node.querySelector(`.list-title`).innerText;
        };
        state.last_node_ptr = node;
    });
    let output_arr = data_arr.filter(obj => {
        return words_arr.map(word => {
            return obj.title.toLowerCase().indexOf(word.toLowerCase()) >= 0;
        }).reduce((a,b) => a || b);
    })
    let result_txt = output_arr.map(obj => {
        return `${obj.id}|${obj.title}`;
    }).join('\n');
    console.log(result_txt);
    copy(result_txt);
})(['llm']);


