package org.proggersworld.javafx_template.modules.mainwindow;

import java.net.URL;
import java.util.ResourceBundle;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;

import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import org.proggersworld.javafx_template.App;
/**
 * FXML Controller class
 *
 * @author proggersworld
 */
public class MainwindowController implements Initializable {

    @FXML
    private Color x2;
    
    @FXML
    private Font x1;
    
    @FXML
    private Color x4;
    
    @FXML
    private Font x3;
    
    private App app;
    
    private MainwindowModel model;
    
    private URL url;
    
    private ResourceBundle rb;
    
    /**
     * Initializes the controller class.
     */
    @Override
    public void initialize(URL url, ResourceBundle rb) {
        this.url = url;
        this.rb = rb;
        this.model = new MainwindowModel();
        
        // TODO: Add your code here.
    }
    
    public void setApp(App app) {
        this.app = app;
    }
    
}
