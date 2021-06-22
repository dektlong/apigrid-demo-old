package io.storebackend.api;

import io.storebackend.api.data.StoreItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.util.ObjectUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@RestController
public class StoreBackendController {

    private static Logger LOG = LoggerFactory.getLogger(StoreBackendController.class);

    @Value("${store-backend.api.limit:100}")
    long _limit;

    //@Value("${cacheUrl:http://localhost:8888}")
    @Value("${cacheUrl}")
    String _cacheUrl;
    private RestTemplate _cacheTemplate = new RestTemplate();

    // @Value("${backendUrl:http://localhost:9090}")
    @Value("${backendUrl}")
    String _backendUrl;
    private RestTemplate _backendTemplate = new RestTemplate();

    private static DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd");
    private static String DEFAULT_GROUP = "Default group";

    @GetMapping("/")
    public List<StoreItem> retrieve() {
        LOG.debug("Retrieving all StoreItems");
        StoreItem[] cached = _cacheTemplate.getForEntity(_cacheUrl, StoreItem[].class).getBody();
        //if cache is empty, hydrate
        if(cached.length < 1) {
            LOG.debug("Cache empty, retrieving from backend service");
            StoreItem[] backendResp = _backendTemplate.getForEntity(_backendUrl, StoreItem[].class).getBody();
            if(backendResp.length > 0)    Arrays.stream(backendResp)
                    .forEach(e->_cacheTemplate.postForObject(_cacheUrl, e, StoreItem.class));
            return Arrays.asList(backendResp);
        } else {
            //Return cached list
            return Arrays.asList(cached);
        }
    }

    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("/")
    public StoreItem create(@RequestBody StoreItem item) {
        // check if cache size is not over the limit
        throwIfOverLimit();

        if(item.getTitle() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "item.title cannot be null on put");
        }

        LOG.debug("Creating StoreItem: " + item);
        StoreItem obj = new StoreItem();
        if(ObjectUtils.isEmpty(item.getId())) {
            obj.setId(UUID.randomUUID().toString());
        } else {
            obj.setId(item.getId());
        }
        if(!ObjectUtils.isEmpty(item.getTitle())) {
            obj.setTitle(item.getTitle());
        }
        if(ObjectUtils.isEmpty(item.getCategory())) {
            obj.setCategory(DEFAULT_GROUP);
        } else {
            obj.setCategory(item.getCategory());
        }
        

        //Write to DB
        StoreItem saved = _backendTemplate.postForObject(_backendUrl, obj, StoreItem.class);
        LOG.debug("Created in Backend");

        //Invalidate/Add Cache
        StoreItem cached = _cacheTemplate.postForObject(_cacheUrl, saved, StoreItem.class);
        LOG.debug("Created in Cache");
        return saved;
    }

    @ResponseStatus(HttpStatus.OK)
    @PostMapping("/{id}")
    public StoreItem put(@PathVariable String id, @RequestBody StoreItem item) {
        if(item.getId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "item.id cannot be null on put");
        }
        if(!item.getId().equals(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "item.id ${item.id} and id $id are inconsistent");
        }

        StoreItem obj = new StoreItem();
        obj.setId(item.getId());

        if(ObjectUtils.isEmpty(item.getCategory())) {
            obj.setCategory(DEFAULT_GROUP);
        } else {
            obj.setCategory(item.getCategory());
        }
      
        //Write to DB
        StoreItem saved = _backendTemplate.postForObject(_backendUrl, obj, StoreItem.class);
        LOG.debug("Created in Backend");

        //Invalidate/Add Cache
        StoreItem cached = _cacheTemplate.postForObject(_cacheUrl, saved, StoreItem.class);
        LOG.debug("Created in Cache");
        return saved;
    }

    @DeleteMapping("/")
    public void deleteAll() {
        LOG.debug("Removing all StoreItems");

        //Remove from DB
        _backendTemplate.delete(_backendUrl);
        //Remove from Cache
        _cacheTemplate.delete(_cacheUrl);
    }

    @GetMapping("/{id}")
    public StoreItem retrieve(@PathVariable("id") String id) {
        LOG.debug("Retrieving StoreItem: " + id);
        //Check cache + DB
        StoreItem cached = null;
        try {
            cached = _cacheTemplate.getForEntity(_cacheUrl + "/" + id, StoreItem.class).getBody();
        } catch (HttpStatusCodeException ex) {
            if(ex.getRawStatusCode() != 404) {
                LOG.error("Caching service error downstream", ex);
                throw ex;
            }
        }

        if(cached != null) {
            // found in cache
            LOG.debug("Found cached version");
            return cached;
        } else {
            LOG.debug("Not in cache, retrieving from backend");

            StoreItem source = null;
            try{
                source = _backendTemplate.getForEntity(_backendUrl + "/" + id, StoreItem.class).getBody();
            } catch (HttpStatusCodeException ex) {
                if(ex.getRawStatusCode() != 404) {
                    LOG.error("Database service error downstream", ex);
                    throw ex;
                }
            }

            if(source != null) {
                LOG.debug("Found in backend");
                cached = _cacheTemplate.postForObject(_cacheUrl, source, StoreItem.class);
                return source;
            }
        }

        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "item.id = " + id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable("id") String id){
        //Remove from DB
        _backendTemplate.delete(_backendUrl + "/" + id);

        //Remove from Cache
        _cacheTemplate.delete(_cacheUrl + "/" + id);
    }

    @PatchMapping("/{id}")
    public StoreItem update(@PathVariable("id") String id, @RequestBody StoreItem item) {
        if(item.getId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "item.id cannot be null on put");
        }
        if(!item.getId().equals(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "item.id ${item.id} and id $id are inconsistent");
        }

        StoreItem obj = new StoreItem();
        obj.setId(item.getId());

        if(!ObjectUtils.isEmpty(item.getTitle())) {
            obj.setTitle(item.getTitle());
        }
        if(ObjectUtils.isEmpty(item.getCategory())) {
            obj.setCategory(DEFAULT_GROUP);
        } else {
            obj.setCategory(item.getCategory());
        }
       
        //Write to DB
        StoreItem saved = _backendTemplate.postForObject(_backendUrl, obj, StoreItem.class);
        LOG.debug("Created in Backend");

        //Invalidate/Add Cache
        StoreItem cached = _cacheTemplate.postForObject(_cacheUrl, saved, StoreItem.class);
        LOG.debug("Created in Cache");
        return saved;
    }

    private void throwIfOverLimit() {
        StoreItem[] cached = _cacheTemplate.getForEntity(_cacheUrl, StoreItem[].class).getBody();
        if(cached.length >= _limit) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "item.api.limit=$limit, item.size=$count");
        } else {
            return;
        }
    }

}
