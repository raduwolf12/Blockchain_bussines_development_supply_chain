pragma solidity >=0.7.0 <0.9.0;

contract ProductSC {
    
    string public name; //deifne a token name
    string public symbol; //define a token symbol
    address payable public  tokenOwner;  //token tokenOwner, the address can receive ether
    uint256 constant tokenPrice = 100; // token price, unit wei
    int256 constant temp_threshold = -10; // temperature temp_threshold
    uint256 constant slot_num = 4;
    
    uint256 private _totalSupply; //the total supply of the tokenOwner
    

    // product state 
    enum State {
        Produced, // 0  Produced by factory
        Ordered, // 1  Sold to distributors
        Shipped, // 2 //shipped by distributors or transporters
        Stored, // 3 //product is stored 
        Received, // 4 // received by retailors
        Purchased // 5 //purchased by consumers
    }
    
    // different roles
    enum Role {
    Producer, // 0 
    Distributor, // 1 
    Retailer, // 2 
    Depository, //3
    Consumer // 4
    }
    
    // define a struct "Product"
    struct Product {
        uint256 ID; // the product identifier
        address ownerID; // the current owner of the product, the first owner is product
        address producerID; // the address of the factory
        uint256[slot_num] timestamp; // different timestamps
        
        State productState;
        uint256 productPrice; 
        address distributorID;
        address retailerID;
        address consumerID;
        Details details;
        
    }
    
    struct Actor {
        Role role;
        string name;
        bool isDefined;
    }

     struct Details {
        string name;
        string brand;
        string size;
        string weight;
        string length ;  
        string width ;  
        string height;
    }
    
     mapping (address => uint256) private balances; //a key-value store, with the address, we can find the token balance of an address
     mapping (address => Actor) private actors;
     mapping (uint256 => Product) private product; // a mapping from productID to a product
    
    // constructor, to be intialized when the contract is deployed 
    constructor (string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;
        tokenOwner = payable(msg.sender); //the address deploying the smart contract
        balances[msg.sender] = _initialSupply; // the balances of the tokenOwner is intialized as the totalsupply
    }
    
    
    // modifier to check if the caller is the token owner
    modifier OnlyTokenOwner() {
        require(msg.sender == tokenOwner, 'caller is not the token owner.');
        _;
    }
    
    modifier OnlyProducer() {
        require(actors[msg.sender].role == Role.Producer,'caller is not a producer.');
        _;
    }
    
     modifier OnlyDistributor() {
        require(actors[msg.sender].role == Role.Distributor, 'caller is not a distributor.');
        _;
    }
    
     modifier OnlyRetailer() {
        require(actors[msg.sender].role == Role.Retailer, 'caller is not a retailer.');
        _;
    }
    
     modifier OnlyDepository() {
        require(actors[msg.sender].role == Role.Depository, 'caller is not a depository.');
        _;
    }


     modifier OnlyConsumer() {
        require(actors[msg.sender].role == Role.Consumer, 'caller is not a consumer.');
        _;
    }
    
      modifier registered(address _addr) {
      require(actors[_addr].isDefined, 'Actor does not exist.');
      _;
    }

    
    //return the token balance of a passed address
    function tokenBalance(address _addr) public view returns (uint256) {
        return balances[_addr];
    }
    
    // return the ether banlance of a passed address
    function etherBalance(address _addr) public view returns (uint256) {
        return _addr.balance;
    }
    
    // token minting, only the token owner can mint tokens, _amount is the number of tokens to be mint
    function mint(uint256 _amount) public OnlyTokenOwner {
        _totalSupply += _amount; // the total token supply increases
        balances[msg.sender] += _amount; //the token balance of the token owner increases
    }
    
    // token burning, only the token owner can burn a certain amount of tokens, 
    // the owner can burn amount of tokens of a given account
    function burn(address _account, uint256 _amount) public OnlyTokenOwner {
        require(_account != address(0)); // the address is a non-zero address (can be the address of the token owner or other accounts)
        require(_amount <= balances[_account]); // the amount of burned should not be more than the current balance
        
        _totalSupply -= _amount;
        balances[_account] -= _amount;
    }
    
    
    // Buy tokens from the token owner
    function buyToken() public payable {
       uint256 tokenNum = msg.value/tokenPrice; //number of tokens to be bought
       require(msg.value > 0); //the paid money should be more than 0
      tokenOwner.transfer(msg.value); //transfer ether from the buyer to the seller (i.e., tokenOwner)
        balances[tokenOwner] -= tokenNum; // the number of tokens held by the token owner decreases
        balances[msg.sender] += tokenNum;  // the buyer gets the corresponding number of tokens
    }
    
    // token transfer from the caller to a specified account
    function tokenTransfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount); // the token balance of the caller should be more than the amount of tokens
        require(_to != address(0));
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }
    
    function register(address _addr, Role _role, string memory _name) public {
        Actor memory actor = actors[_addr];
        actor.role = _role;
        actor.name = _name;
        actor.isDefined = true;
        actors[_addr] = actor;
        
    }
    // produce a product and record the information on the blockchain, only the producer can call this function
    function produceProduct(uint256 _id, uint256 _timestamp, uint256 _price, string memory _name, string memory _brand, string memory _size, string memory _weight, string memory _length ,string memory _width ,string memory _height) public OnlyProducer{
        Product storage newProduct = product[_id];
        newProduct.ID = _id;
        newProduct.ownerID = msg.sender;
        newProduct.producerID = msg.sender;
        newProduct.timestamp[0] = _timestamp;
      
        newProduct.productState= State.Produced;
      
        newProduct.productPrice=_price; 
        newProduct.distributorID=address(0);
        newProduct.retailerID=address(0);
        newProduct.consumerID=address(0);
        newProduct.details.name = _name;
        newProduct.details.brand= _brand;
        newProduct.details.size = _size;
        newProduct.details.weight = _weight;
        newProduct.details.length = _length;  
        newProduct.details.width = _width;  
        newProduct.details.height = _height;
    }

     // buy a product from the seller
    function buyProduct(uint256 _id, uint256 _timestamp) public OnlyDistributor{
        Product storage boughtProduct = product[_id];
        uint256 tokenNumber = balances[msg.sender];
        require(tokenNumber >= boughtProduct.productPrice);
        require(boughtProduct.productState == State.Produced);
        
        product[_id].timestamp[1] = _timestamp;  // update the on-chain information
         product[_id].distributorID = msg.sender;


         tokenTransfer(product[_id].ownerID,boughtProduct.productPrice);
         product[_id].productState = State.Purchased;
         product[_id].ownerID = msg.sender;
        
    }
    
    // retrieve a product's information at a specified time
//     function getProductInfo(uint256 _id, uint256 _timestamp) public view returns 
//     (
//     uint256 fish_id, 
//     address fisher_id, 
//     address owner_id, 
//     string memory fish_origin, 
//    // uint256 time, 
//     string memory lat, 
//     string memory log, 
//     bool quality, 
//     State currentState
//     )
    
//     {
//     fish_id = fish[_id].ID; 
//     fisher_id = fish[_id].fisherID;
//     owner_id = fish[_id].ownerID;
//     fish_origin = fish[_id].origin;
//     lat = fish[_id].latitude[_timestamp];
//     log = fish[_id].longitude[_timestamp];
//     quality = fish[_id].safety;
//     currentState = fish[_id].fishState;
// }
    
//     // retrieve a product's information at a specified time
//     function getFishInfo(uint256 _id, uint256 _timestamp) public view returns 
//     (
//     uint256 fish_id, 
//     address fisher_id, 
//     address owner_id, 
//     string memory fish_origin, 
//    // uint256 time, 
//     string memory lat, 
//     string memory log, 
//     bool quality, 
//     State currentState
//     )
    
//     {
//     fish_id = fish[_id].ID; 
//     fisher_id = fish[_id].fisherID;
//     owner_id = fish[_id].ownerID;
//     fish_origin = fish[_id].origin;
//     lat = fish[_id].latitude[_timestamp];
//     log = fish[_id].longitude[_timestamp];
//     quality = fish[_id].safety;
//     currentState = fish[_id].fishState;
// }

// retrieve an actor's information
function getActorInfo(address _addr) public view returns
(
    Role _role,
    string memory _name
)
{
    _role = actors[_addr].role;
    _name = actors[_addr].name;
}

}