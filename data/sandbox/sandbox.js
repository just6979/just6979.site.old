// gets xhtml chunks from python, built with genshi, data from postgresql

var logReader
var logVisible = true

YAHOO.util.Event.onContentReady('submitbuttons', setupButtons)

// do this stuff after the window loads
YAHOO.util.Event.addListener(window, 'load', onWindowLoad)
function onWindowLoad() {
	loggerInit()
	togShowLog()
	ajaxReq.get('sandbox.py?op=select')
}

var ajaxReq = {
	reqUrl: '',
	success: function(req) {
		YAHOO.log('XHR success: ' + reqUrl)
		replaceContent(req.responseText)
		setupTable()
	},
	failure: function(req) {
		errStr = req.status + ': ' + req.statusText
		YAHOO.log('XHR failure: ' + errStr + ': ' + reqUrl)
		replaceContent('<h2>Error</h2><p><strong>' + errStr + '</strong> while requesting <em>' + reqUrl + '</em></p>')
	},
	get: function(url) {
		reqUrl = url
		YAHOO.log('XHR request: ' + reqUrl)
		YAHOO.util.Connect.asyncRequest('GET', url, cbReplaceContent, null)
	}
}

var cbReplaceContent = {
	success: ajaxReq.success,
	failure: ajaxReq.failure,
	scope: ajaxReq,
	timeout: 20000
}

// create log reader instance
function loggerInit() {
	var logConfig = {
		footerEnabled: false,
		draggable: false
	}
	var logContainer = null
	logReader = new YAHOO.widget.LogReader(logContainer, logConfig)
}

function replaceContent(text) {
	var body = document.getElementById('dataform')
	var content = document.getElementById('content')
	var newContent = document.createElement('div')
	newContent.setAttribute('id', 'content')
	newContent.innerHTML = text
	body.replaceChild(newContent, content)
}

function togShowLog() {
	logVisible = !logVisible
	if (logVisible == false) {
		logReader.show()
	} else {
		logReader.hide()
	}
}

function setupButtons() {
	var btnSelect = new YAHOO.widget.Button({
		type: 'button',
		id: 'btnSelect',
		label: 'SELECT',
		name: 'op',
		container: 'liSelect'
	}).on('click', function() {
		ajaxReq.get('./sandbox.py?op=select')
	})

	var btnInsert = new YAHOO.widget.Button({
		type: 'button',
		id: 'btnInsert',
		label: 'INSERT',
		name: 'op',
		container: 'liInsert'
	}).on('click', function() {
		ajaxReq.get('./sandbox.py?op=insert')
	})

	var btnUpdate = new YAHOO.widget.Button({
		type: 'button',
		id: 'btnUpdate',
		label: 'UPDATE',
		name: 'op',
		container: 'liUpdate'
	}).on('click', function() {
		ajaxReq.get('./sandbox.py?op=update')
	})

	var btnDelete = new YAHOO.widget.Button({
		type: 'button',
		id: 'btnDelete',
		label: 'DELETE',
		name: 'op',
		container: 'liDelete'
	}).on('click', function() {
		var formObject = document.getElementById('dataform')
		YAHOO.log(formObject)
	//	YAHOO.util.Connect.setForm(formObject)
		ajaxReq.get('./sandbox.py?op=delete')
	})

	var btnReset = new YAHOO.widget.Button({
		type: 'reset',
		id: 'btnReset',
		label: 'Reset',
		name: 'op',
		container: 'liReset'
	}).on('click', function() {
		var formObject = $('dataform')
		btnDelete.disabled = true
		formObject.reset()
	})

	var btnShowLog = new YAHOO.widget.Button({
		type: 'checkbox',
		id: 'btnShowLog',
		label: 'Show Log',
		name: 'btnShowLog',
		checked: !logVisible,
		container: 'liShowLog'
	}).on('click', togShowLog)
}






// old datatable stuff
function setupTable() {
	var rowSelected

	YAHOO.util.Event.addListener("datarows", "click", clickedRow)
	YAHOO.util.Event.addListener("btnReset", "click", clickedReset)

	function clickedRow(e) {
		var eTarget = YAHOO.util.Event.getTarget(e)
		while (eTarget.id != "datarows") {
			if(eTarget.nodeName == "tr") {
				selectRow(eTarget)
				break
			} else {
				eTarget = eTarget.parentNode
			}
		}
	}

	function selectRow(row) {
		var rowRadio = document.getElementById(row.id + "Radio")
		// why can't you .click() an HTMLInputElement from YAHOO.util.Selector.query
		//var rowRadio = YAHOO.util.Selector.query("input.rowRadio", row.id)
		var fieldCells = YAHOO.util.Selector.query("td.field", row.id)
		var fieldInputs = YAHOO.util.Selector.query("input.field", "inputfields")

		var fieldCount = fieldInputs.length
		for (var i = 0; i < fieldCount; i++) {
			fieldInputs[i].value = fieldCells[i].textContent
		}

		rowRadio.checked = true

		var updateButton = document.getElementById("btnUpdate")
		var deleteButton = document.getElementById("btnDelete")
		updateButton.disabled = false
		deleteButton.disabled = false

		rowSelected = true
	}

}
