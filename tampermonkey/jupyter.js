// ==UserScript==
// @name     Jupyter increase width
// @include  http://localhost:*/notebooks/*
// @grant    GM_addStyle
// @run-at   document-start
// ==/UserScript==

GM_addStyle ( `
    .container {
        width: 99% !important;
    }
    
    /* Prevent the edit cell highlight box from getting clipped;
     *  * important so that it also works when cell is in edit mode*/
    div.cell.selected {
        border-left-width: 1px !important;
    }
` );
