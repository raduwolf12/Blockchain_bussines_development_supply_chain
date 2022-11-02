pragma solidity >=0.7.0 <0.9.0;

contract ProductSC {
    
    string public name; //deifne a token name
    string public symbol; //define a token symbol
    address payable public  tokenOwner;  //token tokenOwner, the address can receive ether
    uint256 constant tokenPrice = 100; // token price, unit wei
    uint256 constant state_num = 5;
    
    uint256 private _totalSupply; //the total supply of the tokenOwner
    

    // product state 
    enum State {
        Ordered,    // 0 //Ordered by brands
        Produced,   // 1 //Produced by factory
        In_Transit, // 2 //shipped by distributors or transporters and in transit
        Avalaible,  // 3 // reached destination
        Sold        // 4 //Sold to consumers

        
        // Shipped,  // 2 //shipped by distributors or transporters
        // Stored,   // 3 //Product is stored 
        // Received, // 4 //Received by retailors
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
        address ordererID;
        address producerID; // the address of the factory
        uint256[state_num] timestamp; // different timestamps for each state process
        
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
    // constructor (string memory _name, string memory _symbol, uint256 _initialSupply) {
    //     name = _name;
    //     symbol = _symbol;
    //     _totalSupply = _initialSupply;
    //     tokenOwner = payable(msg.sender); //the address deploying the smart contract
    //     balances[msg.sender] = _initialSupply; // the balances of the tokenOwner is intialized as the totalsupply
    // }
    
    // constructor, to be intialized when the contract is deployed 
    constructor (string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        tokenOwner = payable(msg.sender); //the address deploying the smart contract
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
    // function mint(uint256 _amount) public OnlyTokenOwner {
    //     _totalSupply += _amount; // the total token supply increases
    //     balances[msg.sender] += _amount; //the token balance of the token owner increases
    // }
   
    //mint when ordered
    //  function orderProduct(uint256 _amount, string memory _name, string memory _brand, string memory _size, string memory _weight, string memory _length, string memory _width, string memory _height) public OnlyTokenOwner {
    //     uint256 index=0;

    //     if(_totalSupply!=0){
    //         index=_totalSupply;
    //     }

    //       Details memory _details;
    //       _details.name=_name;
    //      _details.brand=_brand;
    //      _details.size=_size;
    //      _details.weight=_weight;
    //      _details.length =_length;
    //      _details.width =_width;
    //      _details.height=_height;
       
    //     for(uint256 i=index;i<index+_amount;i++){
    //         product[i]= Product({  ID:i,
    //         ownerID: address(0),
    //         producerID: address(0),
    //         timestamp: block.timestamp,
    //         productState:State.Ordered,
    //         productPrice:100,
    //         distributorID:address(0),
    //         retailerID:address(0),
    //         consumerID:address(0),
    //         details:_details });
    //     }

    //     _totalSupply += _amount; // the total token supply increases
    //     balances[msg.sender] += _amount; //the token balance of the token owner increases

    // }

    
    // token burning, only the token owner can burn a certain amount of tokens, 
    // the owner can burn amount of tokens of a given account
    function burn(address _account, uint256 _amount) public OnlyTokenOwner {
        require(_account != address(0)); // the address is a non-zero address (can be the address of the token owner or other accounts)
        require(_amount <= balances[_account]); // the amount of burned should not be more than the current balance
        
        _totalSupply -= _amount;
        balances[_account] -= _amount;
    }
    
    
    // // Buy tokens from the token owner
    // function buyToken() public payable {
    //    uint256 tokenNum = msg.value/tokenPrice; //number of tokens to be bought
    //    require(msg.value > 0); //the paid money should be more than 0
    //   tokenOwner.transfer(msg.value); //transfer ether from the buyer to the seller (i.e., tokenOwner)
    //     balances[tokenOwner] -= tokenNum; // the number of tokens held by the token owner decreases
    //     balances[msg.sender] += tokenNum;  // the buyer gets the corresponding number of tokens
    // }
    
    // token transfer from the caller to a specified account
    function tokenTransfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount); // the token balance of the caller should be more than the amount of tokens
        require(_to != address(0));
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }

    function tokenTransferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(balances[_from] >= _amount); // the token balance of the caller should be more than the amount of tokens
        require(_to != address(0));
        
        balances[_from] -= _amount;
        balances[_to] += _amount;
        return true;
    }

    function transferProductTokenBetweenConsumers(address _from, address _to, uint256 product_id) public OnlyConsumer returns (bool) {
        require(balances[_from] >= 1); // the token balance of the caller should be more than the amount of tokens
        require(_to != address(0));
        require(product[product_id].ownerID == _from  );

        Product storage newProduct = product[product_id];
        newProduct.ownerID = _to;

        balances[_from] -= 1;
        balances[_to] += 1;

        return true;
    }

    
    function registerActor(address _addr, Role _role, string memory _name) public {
        Actor memory actor = actors[_addr];
        actor.role = _role;
        actor.name = _name;
        actor.isDefined = true;
        actors[_addr] = actor;
        
    }
    // order a product and record the information on the blockchain, only the producer can call this function
    function orderProduct(uint256 _timestamp, uint256 _price, string memory _name, string memory _brand, string memory _size, string memory _weight, string memory _length ,string memory _width ,string memory _height) public OnlyTokenOwner{
        
        uint256 id=0;

        if(_totalSupply!=0){
            id= _totalSupply+1;
        }

        Product storage newProduct = product[id];
        newProduct.ID = id;
        newProduct.ownerID = msg.sender;
        newProduct.ordererID = msg.sender;
        newProduct.producerID = address(0);
        newProduct.timestamp[0] = _timestamp;
      
        newProduct.productState= State.Ordered;
      
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

        _totalSupply += 1; // the total token supply increases by 1
        balances[msg.sender] += 1;
    }
    function orderProducts(uint256 _amount, uint256 _timestamp, uint256 _price, string memory _name, string memory _brand, string memory _size, string memory _weight, string memory _length ,string memory _width ,string memory _height) public OnlyTokenOwner{
        uint256 index=0;

        if(_totalSupply!=0){
            index=_totalSupply;
        }

    for(uint256 i=index+1;i<index+_amount;i++){
            Product storage newProduct = product[i];
            newProduct.ID = i;
            newProduct.ownerID = msg.sender;
            newProduct.ordererID = msg.sender;
            newProduct.producerID = address(0);
            newProduct.timestamp[0] = _timestamp;
      
            newProduct.productState= State.Ordered;
      
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
        _totalSupply += _amount; // the total token supply increases by 1
        balances[msg.sender] += _amount;

    }




    function produceProduct(uint256 _id, uint256 _timestamp) public OnlyProducer{
        Product storage newProduct = product[_id];
        newProduct.productState= State.Produced;
        newProduct.timestamp[1] = _timestamp;
        product[_id].producerID = msg.sender;
        tokenTransferFrom(product[_id].ownerID,newProduct.producerID,1);
    }

    function shipProduct(uint256 _id, uint256 _timestamp) public OnlyDistributor{
        Product storage newProduct = product[_id];
        newProduct.productState= State.In_Transit;
        newProduct.timestamp[2] = _timestamp;
        product[_id].distributorID = msg.sender;
        tokenTransferFrom(product[_id].producerID,newProduct.distributorID,1);
    }

    function shipProductFinished(uint256 _id, uint256 _timestamp, address retailerID) public OnlyDistributor{
        Product storage newProduct = product[_id];
        newProduct.productState= State.Avalaible;
        newProduct.timestamp[3] = _timestamp;
        product[_id].distributorID = msg.sender;
        tokenTransferFrom(product[_id].distributorID,retailerID,1);

        
    }

    // function reciveProduct(uint256 _id, uint256 _timestamp) public OnlyRetailer{
    //     Product storage boughtProduct = product[_id];
        
    //     product[_id].timestamp[4] = _timestamp;  // update the on-chain information
    //     product[_id].distributorID = msg.sender;


    //     tokenTransfer(boughtProduct.ownerID,1);
    //     product[_id].ownerID = msg.sender;
        
    // }

     // buy a product from the seller
    function sellProduct(uint256 _id, uint256 _timestamp, address newOwner) public OnlyRetailer{
        Product storage boughtProduct = product[_id];
        uint256 tokenNumber = balances[msg.sender];
        require(tokenNumber >= boughtProduct.productPrice);
        require(boughtProduct.productState == State.Produced);
        
        product[_id].timestamp[4] = _timestamp;  // update the on-chain information
        product[_id].retailerID = msg.sender;


        tokenTransfer(product[_id].consumerID,1);

        product[_id].productState = State.Sold;
        product[_id].ownerID = newOwner;
        product[_id].consumerID = newOwner;
    }




    
    // retrieve a product's information at a specified time
    function getProductInfo(uint256 _id) public view returns 
    (
        uint256 product_id, // the product identifier
        address orderer_id,
        address producer_id, // the address of the factory
        address owner_id, // the current owner of the product, the first owner is product

        State currentProductState,
        uint256 productPrice, 
        address distributor_id,
        address retailer_id,
        address consumer_id,
        Details memory details
    )
    
    {
    product_id = product[_id].ID; 
    producer_id = product[_id].producerID;
    orderer_id = product[_id].ordererID;
    owner_id = product[_id].ownerID;
    distributor_id= product[_id].distributorID;
    retailer_id= product[_id].retailerID;
    consumer_id= product[_id].consumerID;

    currentProductState = product[_id].productState;
    productPrice = product[_id].productPrice;

    details= product[_id].details;
}
    function getProductDetails(uint256 _id) public view returns 
    (
        uint256 product_id, // the product identifier
        address owner_id, // the current owner of the product, the first owner is product

        State currentProductState,
        uint256 productPrice, 

        string memory product_name,
        string memory product_brand,
        string memory product_size,
        string memory product_weight,
        string memory product_length,  
        string memory product_width,  
        string memory product_height
    )
    
    {
    product_id = product[_id].ID; 
    owner_id = product[_id].ownerID;

    currentProductState = product[_id].productState;
    productPrice = product[_id].productPrice;
    product_name = product[_id].details.name;
    product_brand= product[_id].details.brand;
    product_size= product[_id].details.size;
    product_weight= product[_id].details.weight;
    product_length= product[_id].details.length;
    product_width= product[_id].details.width;
    product_height= product[_id].details.height;

}


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