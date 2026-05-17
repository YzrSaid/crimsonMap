allprojects {
    repositories {
        google()
        mavenCentral()
        // Make Unity library artifacts (AARs/JARs) available to all projects
        flatDir {
            dirs("${rootProject.projectDir}/unityLibrary/libs")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix for older plugins that don't declare a namespace (required by AGP 8+)
subprojects {
    plugins.withId("com.android.library") {
        val android = extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace.isNullOrEmpty()) {
            android.namespace = project.group.toString().ifEmpty { project.name }
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
