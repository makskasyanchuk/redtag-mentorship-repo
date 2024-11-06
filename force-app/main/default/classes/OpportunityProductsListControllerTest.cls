@isTest
private class OpportunityProductsListControllerTest {

    @TestSetup
    static void makeData(){
        Product2 product = TestDataFactory.createProduct();
    }

    @isTest
    static void testGetProducts() {
        Test.startTest();
        List<Product2> products = OpportunityProductsListController.getProducts();
        Test.stopTest();

        Assert.isTrue(products.size() > 0);
    }

    @isTest
    static void testUpdateProducts() {
        Product2 product = [
            SELECT Id, Name FROM Product2 WHERE Name = 'Test product'
        ];

        List<Product2> productsList = new List<Product2>{product};

        Test.startTest();
        List<Product2> products = OpportunityProductsListController.updateProducts(productsList);
        Test.stopTest();

        Assert.isTrue(products.size() > 0);
    }
}