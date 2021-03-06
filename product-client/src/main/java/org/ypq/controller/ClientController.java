package org.ypq.controller;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.ypq.domain.Product;
import org.ypq.service.ClientProductService;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
public class ClientController {

    private static final Logger LOGGER = LoggerFactory.getLogger(ClientController.class);

    @Autowired
    private ClientProductService clientProductService;

    @RequestMapping(value = "/getOneProduct")
    public Product getOneProduct(Integer id) throws InterruptedException, ExecutionException {
        return clientProductService.getOneProduct(id);
    }

    @RequestMapping(value = "/getProducts")
    public List<Product> getProducts() {
        return clientProductService.getProducts();
    }

    @RequestMapping(value = "/updateProduct")
    public Product updateProduct(int id) {
        return clientProductService.updateProduct(id);
    }

}
