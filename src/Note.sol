// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NoteManager {
    struct Note {
        uint256 id;
        string content;
        address author;
        bool exists; 
    }

    uint256 private nextId = 1;
    mapping(uint256 => Note) private notes;
    uint256[] private noteIds;

    function createNote(string memory _content) public {
        uint256 id = nextId;
        notes[id] = Note({
            id: id,
            content: _content,
            author: msg.sender,
            exists: true
        });
        noteIds.push(id);
        nextId++;
    }

    function getNote(uint256 _id) public view returns (Note memory) {
        require(notes[_id].exists, "Note not found");
        return notes[_id];
    }

    function getAllNoteIds() public view returns (uint256[] memory) {
        return noteIds;
    }

    function updateNote(uint256 _id, string memory _newContent) public {
        require(notes[_id].exists, "Note not found");
        require(notes[_id].author == msg.sender, "Not your note");
        notes[_id].content = _newContent;
    }

    function deleteNote(uint256 _id) public {
        require(notes[_id].exists, "Note not found");
        require(notes[_id].author == msg.sender, "Not your note");

        delete notes[_id];

        for (uint256 i = 0; i < noteIds.length; i++) {
            if (noteIds[i] == _id) {
                noteIds[i] = noteIds[noteIds.length - 1];
                noteIds.pop();
                break;
            }
        }
    }
}
