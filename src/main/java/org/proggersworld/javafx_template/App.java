package org.proggersworld.javafx_template;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import java.io.File;
import java.util.Locale;
import java.util.ResourceBundle;
import javafx.application.Platform;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import org.proggersworld.javafx_template.core.I18N;
import org.proggersworld.javafx_template.modules.mainwindow.MainwindowController;

/**
 * <b>The App class.</b><br><br>
 * The start class for your Application.
 *
 * @since 1.0
 */
public class App extends Application {

    private static Logger logger;

    private Stage window;

    private Parent root;

    private MainwindowController mainCtr;

    private String style = "classic";
    
    private ResourceBundle bundle;
    
    private Locale locale;

    @Override
    public void start(Stage stage) {
        logger.info("Application start");

        // Set here your local. When empty then it takes the default locale.
        // I18N.setLocale(Locale.GERMAN);
        bundle = ResourceBundle.getBundle("i18n.language", I18N.getLocale());

        window = stage;
        try {
            // If you need a login window you can copy the "setMainWindow" to "setLoginWindow". Edit your new code block.
            // Then change the following code to setLoginWindow().
            setMainWindow();
        } catch (Exception ex) {
            logger.info(ex.getMessage());
            System.getLogger(App.class.getName()).log(System.Logger.Level.ERROR, (String) null, ex);
        }

        stage.setOnCloseRequest(t -> {
            cleanExit();
        });
    }

    public static void main(String[] args) {
        String logDir = resolveLogDir();
        System.setProperty("app.logdir", logDir);

        new File(logDir).mkdirs();

        logger = LogManager.getLogger(App.class);

        launch();
    }

    public void setMainWindow() throws Exception {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/views/MainwindowView.fxml"), bundle);
        root = (Parent) loader.load();
        mainCtr = loader.getController();
        mainCtr.setApp(this);
        setWindow(true);
    }

    private void setWindow(Boolean resizeable) {
        Scene scene = new Scene(root);
        scene.getStylesheets().add("/styles/" + style + ".css");
        window.setScene(scene);
        window.setResizable(resizeable);
        window.setTitle(bundle.getString("MAINWINDOW.TITLE"));
        window.centerOnScreen();
        window.show();
    }

    private static String resolveLogDir() {
        String userHome = System.getProperty("user.home");
        String os = System.getProperty("os.name").toLowerCase();

        if (os.contains("win")) {
            String appData = System.getenv("APPDATA");
            if (appData == null || appData.isEmpty()) {
                // Fallback auf userHome
                return userHome + File.separator + "AppData" + File.separator + "Roaming"
                        + File.separator + "javafx_template" + File.separator + "logs";
            }
            return appData + File.separator + "javafx_template" + File.separator + "logs";
        } else {
            // Linux + macOS
            return userHome + File.separator + ".config"
                    + File.separator + "javafx_template" + File.separator + "logs";
        }
    }

    public static void cleanExit() {
        logger.info("Application close");
        Platform.exit();
        System.exit(0);
    }

}
