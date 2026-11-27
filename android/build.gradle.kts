import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        extensions.findByName("android")?.let { androidExt ->
            val compileOptionsMethod = androidExt.javaClass.methods.firstOrNull { it.name == "getCompileOptions" }
            val compileOptions = compileOptionsMethod?.invoke(androidExt)
            compileOptions?.javaClass?.methods?.firstOrNull { it.name == "setSourceCompatibility" }
                ?.invoke(compileOptions, JavaVersion.VERSION_21)
            compileOptions?.javaClass?.methods?.firstOrNull { it.name == "setTargetCompatibility" }
                ?.invoke(compileOptions, JavaVersion.VERSION_21)
        }

        tasks.withType<KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
