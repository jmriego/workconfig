// ==UserScript==
// @name        Jira list
// @namespace   Jira list
// @include     https://#URL#/*/*?filter=50263
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        https://#URL#/*/*?filter=50263
// @grant        none
// @run-at       document-idle
// ==/UserScript==

// INSTRUCTIONS:
// CHANGE #URL# to the url for your jira tickets
// Change the img_assignee.src in after the catch to choose the image you want for Unassigned avatar

function addJiraInfo(jira) {
    var jira_number = jira.getAttribute('data-key');
    const url = 'https://#URL#/rest/api/2/issue/' + jira_number;
    fetch(url, {
        method: 'get',
        headers: {
            "Content-Type": "application/json"
        },
        credentials: "same-origin"
    })
    .then(res => {
        return res.json();
    })
    .then((response) => {
        // create priority icon
        var img_priority = document.createElement('img'); // width, height values are optional params
        img_priority.title = response.fields.priority.name;
        img_priority.src = response.fields.priority.iconUrl;
        img_priority.width = 16;
        img_priority.height = 16;

        // create assignee icon
        var img_assignee = document.createElement('img'); // width, height values are optional params
        try {
            img_assignee.title = response.fields.assignee.displayName;
            img_assignee.src = response.fields.assignee.avatarUrls["16x16"];
        } catch(e) {
            img_assignee.title = 'Unassigned';
            // remember to change this line!
            img_assignee.src = 'https://#URL#/secure/useravatar?size=small&ownerId=jmriego&avatarId=?????';
        }
        img_assignee.width = 16;
        img_assignee.height = 16;

        // create span with status text
        var span = document.createElement("span");
        span.className="myjira-current-status aui-lozenge jira-issue-status-lozenge jira-issue-status-lozenge-" + response.fields.status.statusCategory.colorName;
        span.style.fontSize = "8px";
        span.innerHTML = response.fields.status.name;

        // remove the current status shown in the jira
        var statuses = jira.getElementsByClassName("myjira-current-status");
        for(var i=0; i<statuses.length; i++){
          statuses[i].remove();
        }

        // add priority icon and status text to the first line
        var jira_info = document.createElement("div");
        jira_info.style.cssFloat = "right";
        jira_info.className="myjira-current-status";
        jira_info.appendChild(span);
        jira_info.appendChild(img_assignee);
        jira_info.appendChild(img_priority);
        jira.getElementsByTagName('span')[0].appendChild(jira_info);
        jira.getElementsByClassName('issue-content-container')[0].style.width = "100%";
    });
}

function addJiraInfoAll() {
    // loop through jiras in the list. we only loop through the first list found (but there is only one anyway)
    for (const li of document.querySelectorAll('.issue-list>li')) {
        addJiraInfo(li);
    }
}

// window.setTimeout(function () {
//     addJiraInfoAll();
// }, 3000);


// target element that we will observe
var jira_lists = document.getElementsByClassName("simple-issue-list");
var target = document.body;
if (jira_lists.length > 0) {
    target = jira_lists[0];
    console.log("Found the Jira list");
}

// config object
const config = {
  attributes: true,
  attributeOldValue: true,
  characterData: true,
  characterDataOldValue: true,
  childList: true,
  subtree: true
};

// subscriber function
function subscriber(mutations) {
  var jira_changed = false;

  try {
    mutations.forEach((mutation) => {
      for(var i=0; i<mutation.addedNodes.length; i++){
        if (!mutation.addedNodes[i].className.includes("myjira-current-status")) {
          jira_changed = true;
        }
      }
    });
  } catch(e) {
      // do nothing
  }

  if (jira_changed) addJiraInfoAll();
}

// instantiating observer
const observer = new MutationObserver(subscriber);

// observing target
observer.observe(target, config);
