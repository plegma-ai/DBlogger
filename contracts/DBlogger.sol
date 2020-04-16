pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;


contract DBlogger {
    // Defines a new type with two fields.

    enum Role {Admin, Editor, Author, Subscriber}

    struct User {
        bool isValue;
        address id;
        string name;
        string bio;
        Role role;
        string avatar;
    }

    struct Post {
        bool isValue;
        string title;
        string body;
        address author;
        string image;
    }

    uint256 internal newPostCounter;
    mapping(uint256 => Post) posts;
    uint256[] postIndexs;
    address[] userIndexs;

    mapping(address => User) users;

    /**************************** Constructor **************************/
    constructor() public {
        userIndexs.push(msg.sender);
        users[msg.sender] = User({
            isValue: true,
            id: msg.sender,
            name: "Admin",
            bio: "",
            role: Role.Admin,
            avatar: ""
        });
    }

    /**************************** Modifiers ****************************/

    modifier onlyGuest() {
        if (!users[msg.sender].isValue) {
            _;
        }
    }

    modifier onlyUserOrAbove() {
        if (users[msg.sender].isValue) {
            _;
        }
    }

    modifier onlyAuthorOrAbove() {
        User memory user = users[msg.sender];
        if (user.isValue) {
            if (
                user.role == Role.Author ||
                user.role == Role.Editor ||
                user.role == Role.Admin
            ) {
                _;
            }
        }
    }

    modifier onlySelfOrAdmin(address id) {
        User memory user = users[msg.sender];
        if (user.isValue) {
            if (msg.sender == id || user.role == Role.Admin) {
                _;
            }
        }
    }
    modifier onlyAdmin() {
        User memory user = users[msg.sender];
        if (user.isValue) {
            if (user.role == Role.Admin) {
                _;
            }
        }
    }

    /**************************** Public Methods ***********************/

    /************* Insert Operations ***********/

    function addPost(
        string calldata _title,
        string calldata _body,
        string calldata _image
    ) external onlyAuthorOrAbove returns (uint256 postID) {
        postID = newPostCounter++; // campaignID is return variable
        // Creates new struct and saves in storage. We leave out the mapping type.
        postIndexs.push(postID);
        posts[postID] = Post({
            isValue: true,
            title: _title,
            body: _body,
            author: users[msg.sender].id,
            image: _image
        });
    }

    function registerUser(string calldata _name, string calldata _bio)
        external
        onlyGuest
    {
        userIndexs.push(msg.sender);
        users[msg.sender] = User({
            isValue: true,
            id: msg.sender,
            name: _name,
            bio: _bio,
            role: Role.Subscriber,
            avatar: ""
        });
    }

    function makeAdmin(address id) external onlyAdmin {
        require(users[id].isValue, "User Not Registered");
        users[id].role = Role.Admin;
    }

    /************* Update Operations ***********/

    function editPost(
        uint256 postID,
        string calldata _title,
        string calldata _body
    ) external onlyAuthorOrAbove {
        require(posts[postID].isValue == false, "Post does not");
        Post memory post = posts[postID];
        User memory author = users[post.author];
        require(
            !(post.author == msg.sender || author.role != Role.Author),
            "Only Author of the post or an Editor/Admin can edit posts"
        );
        posts[postID].title = _title;
        posts[postID].body = _body;
    }

    function editPostImage(uint256 postID, string calldata _image)
        external
        onlyAuthorOrAbove
    {
        require(posts[postID].isValue == false, "Post does not");
        Post memory post = posts[postID];
        User memory author = users[post.author];
        require(
            !(post.author == msg.sender || author.role != Role.Author),
            "Only Author of the post or an Editor/Admin can edit posts"
        );
        posts[postID].image = _image;
    }

    function editUser(string calldata _name, string calldata _bio)
        external
        onlyUserOrAbove
    {
        users[msg.sender].name = _name;
        users[msg.sender].bio = _bio;
    }

    function editUseravatar(string calldata _avatar) external onlyUserOrAbove {
        users[msg.sender].avatar = _avatar;
    }

    function editUserRole(address id, Role _role) external onlyAdmin {
        require(users[id].isValue == false, "User not registered");
        if (users[id].role == Role.Admin) {
            require(
                id == msg.sender,
                "You dont have permission to perform the action"
            );
        }
        users[id].role = _role;
    }

    /************* Delete Operations ***********/

    function deletePost(uint256 postID) external onlyAuthorOrAbove {
        delete posts[postID];
        uint256 index = postIndexs.length;
        for (uint256 i = 0; i < postIndexs.length - 1; i++) {
            if (postIndexs[i] == postID) index = i;
            if (index < postIndexs.length - 1) {
                postIndexs[i] = postIndexs[i + 1];
            }
        }
        if (index < postIndexs.length) {
            delete postIndexs[postIndexs.length - 1];
        }
        postIndexs.pop();
    }

    function deleteUser(address id) public {
        require(
            id == msg.sender || users[msg.sender].role == Role.Admin,
            "You dont have permission to perform the action"
        );
        if (users[msg.sender].role == Role.Admin) {
            require(
                id == msg.sender,
                "You dont have permission to perform the action"
            );
        }
        User memory user = users[id];
        require(user.isValue, "user does not exist");
        delete users[id];
        uint256 index = userIndexs.length;
        for (uint256 i = 0; i < userIndexs.length - 1; i++) {
            if (userIndexs[i] == id) index = i;
            if (index < postIndexs.length - 1) {
                userIndexs[i] = userIndexs[i + 1];
            }
        }
        if (index < userIndexs.length) {
            delete userIndexs[userIndexs.length - 1];
        }
        userIndexs.pop();
    }

    /************* View Operations ***********/
    function getMyProfile() public view returns (User memory user) {
        require(users[msg.sender].isValue, "User not registered");
        user = users[msg.sender];
        return user;
    }

    function getUser(address id) public view returns (User memory) {
        return (users[id]);
    }

    function getAllUser() public view returns (User[] memory, uint256 count) {
        User[] memory userList = new User[](userIndexs.length);
        for (uint256 i = 0; i < userIndexs.length; i++) {
            userList[i] = users[userIndexs[i]];
        }
        return (userList, userIndexs.length);
    }

    function getPost(uint256 postID) public view returns (Post memory) {
        return posts[postID];
    }

    function getAllPost()
        public
        view
        returns (Post[] memory, uint256[] memory)
    {
        Post[] memory postList = new Post[](postIndexs.length);
        uint256[] memory Ids = new uint256[](postIndexs.length);
        for (uint256 i = 0; i < postIndexs.length; i++) {
            postList[i] = posts[postIndexs[i]];
            Ids[i] = postIndexs[i];
        }
        return (postList, Ids);
    }

    function getAllPostAuthor(address id, uint256 startIndex)
        public
        view
        returns (Post[100] memory, uint256 nextIndex)
    {
        require(users[id].isValue, "User does not exist");

        Post[100] memory postList;
        nextIndex = 0;
        uint256 count = 0;
        if (startIndex >= postIndexs.length) return (postList, nextIndex);
        for (uint256 i = 0; i < postIndexs.length; i++) {
            if (i >= startIndex && posts[postIndexs[i]].author == id) {
                postList[i] = posts[postIndexs[i]];
                count++;
            }
            nextIndex = i;
            if (count >= 100) break;
        }
        nextIndex++;
        if (nextIndex >= postIndexs.length) nextIndex = 0;
        return (postList, nextIndex);
    }

    /*************************** Enum to String *******************************/
    function getRoleName(Role role) public pure returns (string memory) {
        if (role == Role.Admin) return "Admin";
        if (role == Role.Editor) return "Editor";
        if (role == Role.Author) return "Author";
        if (role == Role.Subscriber) return "Subscriber";
    }
}
