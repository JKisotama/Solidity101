// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Notes is Ownable {
    enum Status {
        Active,
        Archived
    }

    // Gas optimization: Pack variables into 32-byte slots
    struct Note {
        uint128 id; // 16 bytes
        uint64 timestamp; // 8 bytes
        Status status; // 1 byte
        string title; // 32 bytes (pointer)
        string content; // 32 bytes (pointer)
    }

    // Gas optimization: Use uint128 instead of uint256 for counters
    mapping(address => uint128) private nextId;
    mapping(address => mapping(uint128 => Note)) private notesByUser;
    mapping(address => mapping(uint128 => bool)) private exists;

    event NoteCreated(address indexed user, uint128 indexed id, string title);
    event NoteUpdated(address indexed user, uint128 indexed id, string newTitle);
    event NoteArchived(address indexed user, uint128 indexed id);
    event NoteDeleted(address indexed user, uint128 indexed id);

    constructor() Ownable(msg.sender) {}

    function createNote(string memory _title, string memory _content) public {
        uint128 id = nextId[msg.sender];

        // Gas optimization: Use assembly for timestamp
        uint64 currentTimestamp;
        assembly {
            currentTimestamp := timestamp()
        }

        notesByUser[msg.sender][id] =
            Note({id: id, timestamp: currentTimestamp, status: Status.Active, title: _title, content: _content});

        exists[msg.sender][id] = true;
        emit NoteCreated(msg.sender, id, _title);

        // Gas optimization: Use unchecked for overflow protection
        unchecked {
            nextId[msg.sender]++;
        }
    }

    function getNote(address user, uint128 _id) public view returns (Note memory) {
        require(exists[user][_id], "Note does not exist");
        return notesByUser[user][_id];
    }

    function updateNote(uint128 _id, string memory _newTitle, string memory _newContent) public {
        require(exists[msg.sender][_id], "Note does not exist");
        Note storage note = notesByUser[msg.sender][_id];
        require(note.status == Status.Active, "Note is archived");

        // Gas optimization: Update timestamp
        uint64 updateTimestamp;
        assembly {
            updateTimestamp := timestamp()
        }

        note.title = _newTitle;
        note.content = _newContent;
        note.timestamp = updateTimestamp;

        emit NoteUpdated(msg.sender, _id, _newTitle);
    }

    function archiveNote(uint128 _id) public {
        require(exists[msg.sender][_id], "Note does not exist");
        Note storage note = notesByUser[msg.sender][_id];
        note.status = Status.Archived;
        emit NoteArchived(msg.sender, _id);
    }

    function deleteNote(uint128 _id) public {
        require(exists[msg.sender][_id], "Note does not exist");
        delete notesByUser[msg.sender][_id];
        exists[msg.sender][_id] = false;
        emit NoteDeleted(msg.sender, _id);
    }

    function noteExists(address user, uint128 _id) public view returns (bool) {
        return exists[user][_id];
    }

    function nextNoteId(address user) public view returns (uint128) {
        return nextId[user];
    }

    // Gas optimization: Use assembly for balance check
    function getBalance() public view returns (uint256) {
        uint256 currentBalance;
        assembly {
            currentBalance := selfbalance()
        }
        return currentBalance;
    }

    // Gas optimization: Use assembly for ETH transfer
    function withdraw() external onlyOwner {
        uint256 currentBalance = getBalance();
        require(currentBalance > 0, "No balance to withdraw");

        assembly {
            let success := call(gas(), caller(), currentBalance, 0, 0, 0, 0)
            if iszero(success) { revert(0, 0) }
        }
    }

    // Gas optimization: Batch operations
    function createMultipleNotes(string[] memory _titles, string[] memory _contents) public {
        require(_titles.length == _contents.length, "Arrays length mismatch");

        uint128 startId = nextId[msg.sender];
        uint64 currentTimestamp;
        assembly {
            currentTimestamp := timestamp()
        }

        for (uint256 i = 0; i < _titles.length;) {
            uint128 id = startId + uint128(i);
            notesByUser[msg.sender][id] = Note({
                id: id,
                timestamp: currentTimestamp,
                status: Status.Active,
                title: _titles[i],
                content: _contents[i]
            });
            exists[msg.sender][id] = true;
            emit NoteCreated(msg.sender, id, _titles[i]);

            unchecked {
                i++;
            }
        }

        unchecked {
            nextId[msg.sender] += uint128(_titles.length);
        }
    }
}
